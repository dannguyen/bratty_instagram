require 'lib/bratty_response'
require 'andand'

class APIWrapper
  attr_reader :clients

  # pass something directly to the client
  # e.g. twitter_wrapper.raw('user', 'skift')
  def raw(*args)
    raw_client.send(*args)
  end

  # get access to a client
  # e.g.
  # t = twitter_wrapper.raw_client
  # t.user('skift')
  def raw_client
    clients.shuffle.first
  end

  # this is the predefined-wrapped up way to do API calls
  # as it will wrap things up in a BrattyResponse
  def fetch(foo, *args)
    self.class.fetch(@clients, foo, *args)
  end

  def self.fetch(clients, str, *args)
    results = []
    self.module_eval('Fetchers').send(str, *args) do |job_type, fetch_proc, args_as_key|
      begin
        client = clients.first
        resp = fetch_proc.call(client)
      rescue => err

        # if err < Twitter
        #   retry
        # end

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
