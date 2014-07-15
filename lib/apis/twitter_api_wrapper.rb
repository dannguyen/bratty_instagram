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
          foo_proc = Proc.new do |client|
            clean_uids = uids.map{|x| clean_screen_name(x) }
            users = client.users(clean_uids, opts)

            glob_users(users, clean_uids)
          end

          yield :batch, foo_proc, uids
        end
      end

      # sample return value:
      # [#<BrattyResponse:0x007fe1a2969ca0
      #   @error=nil,
      #   @message="Success",
      #   @params="JohnDoe",
      #   @response=
      #    [#<Twitter::Tweet id=484784608823623680>,
      #     #<Twitter::Tweet id=484440173195706368>,
      #     #<Twitter::Tweet id=484119493728149504>,
      #     ...
      #  ]

      def content_items_for_user(uid, options = {})
        opts = HashWithIndifferentAccess.new(options)
        opts['include_entities'] ||= true
        opts['count'] ||= 200

        fetch_proc = Proc.new do |client|
          client.user_timeline(uid, opts)
        end

        yield :single, fetch_proc, uid
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
          users_arr = users.map{|u| HashWithIndifferentAccess.new(u.to_h) }
          ukeys.inject({}) do |h, key|
            uhsh = users_arr.find{|u| key.is_a?(Fixnum) ? u[:id].to_i == key : u[:screen_name].downcase == key.downcase }
            h[key] = uhsh.nil? ? StandardError.new("Username: #{key} not found") : uhsh

            h
          end
        end
    end
  end

end
