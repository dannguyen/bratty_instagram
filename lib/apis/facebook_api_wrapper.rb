require 'koala'
require 'apis/api_wrapper'

class FacebookAPIWrapper < APIWrapper
  def initialize(auth_creds)
    @clients = auth_creds.each do |cred|
      token = cred['token']
      Koala::Facebook::API.new(token)
    end
  end
end
