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
      def users(uids, &blk)
        Array(uids).each do |userid_val|
          fetch_proc = Proc.new do |client|
            client.get_object(userid_val)
          end

          yield :single, fetch_proc, userid_val
        end
      end
    end
  end


end
