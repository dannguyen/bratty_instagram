require 'instagram'
require 'lib/bratty_response'

module InstagramAPIWrapper
  INSTAGRAM_ID_PATTERN = /^\d{3,}$/
  class << self
    attr_reader :client_id, :client_secret, :redirect_uri, :access_token
  end

  module AuthStuff

    def config_auth!(auth_opts={})
      Instagram.configure do |config|
        @client_id = config.client_id = auth_opts['client_id']
        @client_secret = config.client_secret = auth_opts['client_secret']
      end

      @access_token =  auth_opts['access_token']
      @redirect_uri = auth_opts['redirect_uri']
    end

    def init_client!
      @client = Instagram.client(access_token: @access_token)
    end


    ### Oauth stuff, may not be needed
    def authorize_url
      Instagram.authorize_url(:redirect_uri => self.redirect_uri)
    end


    def set_access_token(token)
      @access_token = token
    end

    def has_access_token?
      !@access_token.nil?
    end

    def get_access_token(code)
      response = Instagram.get_access_token(code, redirect_uri: self.redirect_uri )

      return response.access_token
    end
  end
  extend AuthStuff

  module Fetchers
    class << self
      # uids is an array of user_ids or names
      def users(uids, &blk)
        uids.each do |userid_val|
          fetch_proc = Proc.new do |client|
            uid = translate_to_user_id(client, userid_val)
            val = client.user(uid)
          end

          yield fetch_proc, userid_val
        end
      end

        private
        # Return a Instagram::User ID from a uname like 'snoopdogg'
        def search_for_user_id_from_username(client, uname)
          arr = client.user_search(uname)
          u = arr.find{|h| h['username'].downcase == uname}
          raise InstagramUsernameDoesntExist, "Could not find user #{uname}" if u.nil?

          u
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
            uid = search_for_user_id_from_username(client, uname)

            return uid
          end
        end
    end
  end


  def self.fetch(str, *args)
    client = init_client!
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
