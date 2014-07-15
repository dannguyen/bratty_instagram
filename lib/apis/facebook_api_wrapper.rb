require 'koala'
require 'apis/api_wrapper'

class FacebookAPIWrapper < APIWrapper
  def initialize(auth_creds)
    @clients = auth_creds.map do |cred|
      token = cred['token']

      Koala::Facebook::API.new(token)
    end
  end

  module Fetchers
    class << self
      # uids is an array of user_ids or names
      def users(user_ids, &blk)
        Array(user_ids).each do |uid|
          fetch_proc = Proc.new do |client|
            client.get_object(uid)
          end

          yield :single, fetch_proc, uid
        end
      end

      def content_items_for_user(uid, opts)
        # use get_connections(uid, :feed)
      end
    end
  end


end
