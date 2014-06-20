require 'twitter'
require 'lib/bratty_response'

class TwitterAPIWrapper


  # auth_keys looks like:

  #   {consumer_key: "KEY",
  #   consumer_secret: "SEC",
  #   oauth_token: "15sadlfkj",
  #   oauth_token_secret: "OAUTHS"}

  def initialize(auth_keys)
    arr = auth_keys.is_a?(Hash) ? [auth_keys] : Array(auth_keys)
    @clients = arr.map do |a|
      Twitter::REST::Client.new(a)
    end
  end



  module Fetchers
    class << self
      def users(clients, arr)
        clients.first.users(Array(arr)).each do |result|

        end
      end
    end

    def fetch(foo, *args)
      Fetchers.send(foo, @clients, *args).each do
    end
  end



end
