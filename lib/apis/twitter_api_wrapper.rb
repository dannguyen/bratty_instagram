require 'twitter'
require 'lib/bratty_response'

class TwitterAPIWrapper


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


  def fetch(foo, *args)
    self.class.fetch(@clients, foo, *args)
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

      def users(all_uids, opts={})
        opts['include_entities'] ||= true

        Array(all_uids).each_slice(TWITTER_MAX_BATCH_USER_SIZE) do |uids|
          foo_proc = Proc.new do |clients|
            client = clients.first
            clean_uids = uids.map{|x| clean_screen_name(x) }
            users = client.users(clean_uids, opts)

            glob_users(users, clean_uids)
          end

          yield :batch, foo_proc, uids
        end
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
            h[key] = uhsh.nil? ? StandardError.new("#{key} not found") : uhsh

            h
          end
        end


    end
  end


  def self.fetch(clients, str, *args)
    results = []
    Fetchers.send(str, *args) do |job_type, fetch_proc, args_as_key|
      begin
        resp = fetch_proc.call(clients)
      rescue => err
        if job_type == :batch
          results += args_as_key.map{|a| BrattyResponse.error(a, err) }
        else
          results << BrattyResponse.error(args_as_key, err)
        end
      else
        if job_type == :batch
          results += resp.map do |ax, aval|
            BrattyResponse.success_or_error(ax, aval)
          end
        else
          results << BrattyResponse.success_or_error(args_as_key, resp)
        end
      end
    end

    return results
  end


end
