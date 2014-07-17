require 'instagram'
require 'apis/api_wrapper'

class InstagramAPIWrapper < APIWrapper
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


  module Fetchers
    class << self
      # uids is an array of user_ids or names
      def users(uids, &blk)
        Array(uids).each do |userval|
          foop = Proc.new do |client|
            uid = translate_to_user_id(client, userval)

            client.user(uid)
          end

          yield :single, foop, userval
        end
      end

      def content_items_for_user(uid, options={})
        opts = HashWithIndifferentAccess.new(options)
        # TK set itemlimit and batch sleep

        # TK set before/after
        # TK convert to seconds as needed

        collected_media = []
        foop = Proc.new do |client|
          # TK call client method


          collected_media
        end

        yield :single, foop, uid
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
        ### private
    end
  end


end


class InstagramApiWrapperError < StandardError; end
class InstagramUsernameDoesntExist < InstagramApiWrapperError; end
