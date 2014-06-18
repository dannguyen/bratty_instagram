require 'instagram'


module InstagramAPIWrapper
  class << self
    attr_reader :client_id, :client_secret, :redirect_uri, :access_token
  end

  module AuthStuff
    def authorize_url
      Instagram.authorize_url(:redirect_uri => self.redirect_uri)
    end

    def config_auth!(auth_opts={})
      Instagram.configure do |config|
        @client_id = config.client_id = auth_opts['client_id']
        @client_secret = config.client_secret = auth_opts['client_secret']
      end

      @redirect_uri = auth_opts['redirect_uri']
    end

    def set_access_token(token)
      @access_token = token
    end

    def get_access_token(code)
      response = Instagram.get_access_token(code, redirect_uri: self.redirect_uri )

      return response.access_token
    end

    def init_client!
      @client = Instagram.client(access_token: @access_token)
    end

  end
  extend AuthStuff



  module Fetchers
    # uids is an array of user_ids or names
    def self.users(client, arr)
      arr.each do |some_key|
        uid = translate_to_user_id(client, some_key)
        val = client.user(uid)

        yield(some_key, val) if block_given?

        [some_key, val]
      end
    end


    def self.search_for_user_id_from_username(uname)
    end

    # val is a String
    #
    # returns actual instagram user ids, mapped to Hash
    # {'snoopdogg' => 8273372, '9349438' => 9349438, 'https://instagram.com/danwinny' => 7123452 }
    def self.translate_to_user_id(client, val)
      u = val.strip
      uid = u[/insatgram.com\/\w+/] || u

      # note, this should delegate to the search method
#      xid = search_for_user_id_from_username(uid)
      return (uid =~ /^\d{3,}$/) ? uid : uid
    end
  end


  def self.fetch(str, *args)
    client = init_client!
    hsh = {}
    Fetchers.send(str, client, *args) do |key, result|
      hsh[key] = result
    end

    return hsh
  end





end
