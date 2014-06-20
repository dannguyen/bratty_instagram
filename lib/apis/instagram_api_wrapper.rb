require 'instagram'
require 'lib/bratty_response'

class InstagramAPIWrapper
  INSTAGRAM_ID_PATTERN = /^\d{3,}$/

  def initialize(auth_opts)
    @clients = auth_opts.map do |a|
      client = Instagram::Client.new
      client.client_id = a['id']
      client.access_token = a['access_token']

      client
    end
    # new Keys format TK
  end


  def fetch(foo, *args)
    self.class.fetch(@clients, foo, *args)
  end


  module Fetchers
    class << self
      # uids is an array of user_ids or names
      def users(uids, &blk)
        Array(uids).each do |userid_val|
          fetch_proc = Proc.new do |client|
            uid = translate_to_user_id(client, userid_val)
            val = client.user(uid)
          end

          yield fetch_proc, userid_val
        end
      end

        private
        # Return a Instagram::User ID from a uname like 'snoopdogg'
        def search_for_user_from_username(client, uname)
          arr = client.user_search(uname)
          user = arr.find{|h| h['username'].downcase == uname.downcase}
          raise InstagramUsernameDoesntExist, "Could not find user #{uname}" if user.nil?

          return user
        end

        # val is a String
        #
        # returns actual instagram user ids, mapped to Hash
        # {'snoopdogg' => 8273372, '9349438' => 9349438, 'https://instagram.com/danwinny' => 7123452 }
        def translate_to_user_id(client, val)
          u = val.strip

          if u =~ INSTAGRAM_ID_PATTERN
            return u
          else
            # extract user name as part of a hash
            uname = u[/(?<=instagram\.com\/)\w+/] || u
            user = search_for_user_from_username(client, uname)

            return user['id']
          end
        end
    end
  end


  def self.fetch(clients, str, *args)
    client = clients.first
    results = []

    Fetchers.send(str, *args) do |fetch_proc, args_as_key|
      begin
        resp = fetch_proc.call(client)
      rescue => err
        results << BrattyResponse.error(args_as_key, err)
      else
        results << BrattyResponse.success(args_as_key, resp)
      end
    end

    return results
  end
end


class InstagramApiWrapperError < StandardError; end
class InstagramUsernameDoesntExist < InstagramApiWrapperError; end
