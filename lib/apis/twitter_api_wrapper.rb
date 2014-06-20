require 'twitter'
require 'lib/bratty_response'

class TwitterAPIWrapper


  # auth_keys looks like:

  #   {consumer_key: "KEY",
  #   consumer_secret: "SEC",
  #   oauth_token: "15sadlfkj",
  #   oauth_token_secret: "OAUTHS"}

  AUTH_FIELDS = %w(consumer_key consumer_secret oauth_token oauth_token_secret)

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

      def users(uids, opts={})
        opts['include_entities'] ||= true

        Array(uids).each do |uid|
          foo_proc = Proc.new do |clients|
            client = clients.first
            client.users(uid, opts)[0]
          end

          yield foo_proc, uid
        end
      end


    end
  end


  def self.fetch(clients, str, *args)
    results = []
    Fetchers.send(str, *args) do |fetch_proc, args_as_key|
      begin
        resp = fetch_proc.call(clients)
      rescue => err
        results << BrattyResponse.error(args_as_key, err)
      else
        results << BrattyResponse.success(args_as_key, resp)
      end
    end

    return results
  end


end
