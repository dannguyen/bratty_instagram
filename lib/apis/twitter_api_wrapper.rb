require 'twitter'
require 'apis/api_wrapper'

class TwitterAPIWrapper < APIWrapper

  # auth_keys looks like:

  #   {consumer_key: "KEY",
  #   consumer_secret: "SEC",
  #   oauth_token: "15sadlfkj",
  #   oauth_token_secret: "OAUTHS"}

  AUTH_FIELDS = %w(consumer_key consumer_secret oauth_token oauth_token_secret)
  TWITTER_MAX_BATCH_USER_SIZE = 100
  TWITTER_MAX_BATCH_TWEET_SIZE = 100
  MAX_TWEET_ID = (2**62) - 1
  MAX_NUMBER_OF_TWEETS_RETRIEVABLE = 3200

  def initialize(auth_keys)
    arr = auth_keys.is_a?(Hash) ? [auth_keys] : Array(auth_keys)
    @clients = arr.map do |a|
      auth = AUTH_FIELDS.inject({}){|h, k| h[k] = a[k]; h}

      Twitter::REST::Client.new(auth)
    end
  end



  module Fetchers
    class << self
      def users(all_uids, options={})
        opts = HashWithIndifferentAccess.new(options)
        opts['include_entities'] ||= true

        Array(all_uids).each_slice(TWITTER_MAX_BATCH_USER_SIZE) do |uids|
          foop = Proc.new do |clients|
            client = clients.pop
            clean_uids = uids.map{|x| clean_screen_name(x) }
            users = client.users(clean_uids, opts)

            glob_users(users, clean_uids)
          end

          yield :batch, foop, uids
        end
      end

      #############
      # get individual tweets
      def content_items(tweets_ids, options={})
        opts = HashWithIndifferentAccess.new(options)
        # by default, we assume that we need user information with standalone tweets
        opts['trim_user']         =  opts['trim_user'].to_s == 'true' ? true : false

        Array(tweets_ids).each_slice(TWITTER_MAX_BATCH_TWEET_SIZE) do |batch_ids|
          foop = Proc.new do |clients|
            client = clients.pop
            batch_of_tweets = client.statuses(batch_ids, opts)
            glob_tweets(batch_of_tweets, batch_ids)
          end

          yield :batch, foop, batch_ids
        end
      end

      ###################
      # TwitterApiWrapper#content_items_for_user
      #
      # e.g. user_timeline
      #
      # sample return value:
      # [#<BrattyResponse:0x007fe1a2969ca0
      #   @error=nil,
      #   @message="Success",
      #   @params="JohnDoe",
      #   @response=
      #    [#<Twitter::Tweet id=484784608823623680>,
      #     #<Twitter::Tweet id=484440173195706368>,
      #     ...
      #  ]
      def content_items_for_user(user_id, options = {})

        user_id = Array(user_id)[0] # silly hack for web interface for now
        opts = HashWithIndifferentAccess.new(options)
        opts['include_entities']  =  opts['include_entities'].to_s == 'false' ? false : true
        opts['trim_user']         =  opts['trim_user'].to_s == 'false' ? false : true
        opts['include_rts']       =  opts['include_rts'].to_s == 'false' ? false : true
        opts['count'] = (opts.delete('batch_size') || 200).to_i
        batch_limit  = (opts.delete('batch_limit') || (MAX_NUMBER_OF_TWEETS_RETRIEVABLE / opts['count'].to_f).ceil).to_i
        batch_sleep = opts.delete('batch_sleep').to_f
        ## setting before and after
        # :max_id/:before sets the upper_bounds of what tweets to include
        #  if it is not set, then we assume the user wants to fetch from the latest tweet
        #  and move backwards, hence, setting max_id to the largest possible tweet ID
        _xbefore = opts.delete('before').to_i # don't want these to be sent to the API
        _xafter = opts.delete('after').to_i
        opts['max_id']   = _xbefore == 0 ? MAX_TWEET_ID : _xbefore
        opts['since_id'] = _xafter  == 0 ? 1 : _xafter

        foop = Proc.new do |clients|
          client = clients.pop
          collected_tweets = []
          nxt_step = HashWithIndifferentAccess.new

          b_count = 0
          while b_count <= batch_limit
            b_count += 1
#           begin

            resp = client.user_timeline(user_id, opts.merge(nxt_step))
            tweets = resp.map{ |t| HashWithIndifferentAccess.new(t.to_h) }
              collected_tweets.concat tweets
#           rescue => err
#              if err is a Timeout
#                raise Timeout and yield a client
#                then retry
#              end
#           else
#
#
#           end
            # assuming that we're going back in time, we want to set
            # max_id to be the oldest of this current batch, i.e. the last tweet
            nxt_step['max_id'] = tweets.last.nil? ? nil : tweets.last['id']
            puts "Next step: #{nxt_step['max_id']}"
            break if ( resp.nil? || resp.empty? ) ||
                      ## max_id is nil, or less than since_id
                      ( nxt_step['max_id'].nil? || nxt_step['max_id'].to_i <= opts['since_id'].to_i )

            # decrement max_id so that the same tweet isn't collected twice
            nxt_step['max_id'] = nxt_step['max_id'].to_i - 1
            sleep batch_sleep
          end
          # return collected tweets
          collected_tweets
        end

        yield :single, foop, user_id
      end

      private
        # basically removes twitter.com/thing
        def clean_screen_name(val)
          if val.is_a?(Fixnum)
            return val
          else
            return val[/(?<=twitter\.com\/)\w+/] || val
          end
        end

        def glob_users(users, ukeys)
          users_arr = users.map{ |u| HashWithIndifferentAccess.new(u.to_h) }
          ukeys.inject({}) do |h, key|
            found_user = users_arr.find{|u| key.is_a?(Fixnum) ? u[:id].to_i == key : u[:screen_name].downcase == key.downcase }
            h[key] = found_user || StandardError.new("User, #{key}, not found")

            h
          end
        end

        # the same code as above, without having to worry about :screen_name vs :id
        def glob_tweets(tweets, tweet_ids)
          arr = tweets.map{ |t| HashWithIndifferentAccess.new(t.to_h) }
          tweet_ids.inject({}) do |h, t_id|
            found_tweet = arr.find{ |tweet| tweet[:id].to_i == t_id.to_i } # see if the results include the requested tweet id
            h[t_id] = found_tweet || StandardError.new("Tweet ID, #{t_id}, not found")

            h
          end
        end

    end
  end
end
