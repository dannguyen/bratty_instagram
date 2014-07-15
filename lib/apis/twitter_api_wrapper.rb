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

  def initialize(auth_keys)
    arr = auth_keys.is_a?(Hash) ? [auth_keys] : Array(auth_keys)
    @clients = arr.map do |a|
      auth = AUTH_FIELDS.inject({}){|h, k| h[k] = a[k]; h}

      Twitter::REST::Client.new(auth)
    end
  end




  module Fetchers
    class << self
      # def users(clients, uids, opts={})
      #   client = clients.first
      #   userids = Array(uids)

      #   fetch_proc = Proc.new do |c|
      #     user_arr = client.users(userids)
      #     # STUCK HERE
      #     userids.each do |uid|

      #     end
      #   end
      # end

      def users(all_uids, options={})
        opts = HashWithIndifferentAccess.new(options)
        opts['include_entities'] ||= true

        Array(all_uids).each_slice(TWITTER_MAX_BATCH_USER_SIZE) do |uids|
          foop = Proc.new do |client|
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
        t_opts = HashWithIndifferentAccess.new(options)
        Array(tweets_ids).each_slice(TWITTER_MAX_BATCH_TWEET_SIZE) do |batch_ids|
          foop = Proc.new{ |client|
            batch_of_tweets = client.statuses(batch_ids, t_opts)
            glob_tweets(batch_of_tweets, batch_ids)
          }

          yield :batch, foop, batch_ids
        end
      end



      ###################
      # TwitterApiWrapper#content_items_for_user
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
      def content_items_for_user(uid, options = {})
        t_opts = HashWithIndifferentAccess.new(options)
        t_opts['contributor_details'] ||= true
        t_opts['include_entities'] ||= true
        t_opts['count'] ||= 200
        t_opts['trim_user'] = (t_opts['trim_user'] == false) ? false : true

        ## seting before and after
        # :max_id/:before sets the upper_bounds of what tweets to include
        #  if it is not set, then we assume the user wants to fetch from the latest tweet
        #  and move backwards, hence, setting max_id to the largest possible tweet ID
        t_opts['max_id']   = t_opts['before'].to_i == 0 ? MAX_TWEET_ID : t_opts['before'].to_i
        t_opts['since_id'] = t_opts['after'].to_i  == 0 ? 1 : t_opts['after'].to_i

        foop = Proc.new do |client|
          client.user_timeline(uid, t_opts).map{ |t| HashWithIndifferentAccess.new(t.to_h) }
        end

        yield :single, foop, uid
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
