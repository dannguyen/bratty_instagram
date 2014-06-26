# todo: move to Bratty module
class BrattyResponse

  attr_reader :params, :response, :error, :message, :status

  def initialize(resp_type, original_params, opts={})
    @status = resp_type.to_sym
    @params = original_params

    @error = opts[:error]
    @message = opts[:message]
    @response = opts[:response]
  end

  def body
    @response
  end

  def error?
    @status == :error
  end

  def success?
    @status == :success
  end

  def to_h
    {
      'error' => @error,
      'params' => @params,
      'message' => @message,
      'response' => @response,
      'status' => @status
    }
  end

  def self.error(params, err, msg=nil)
    message = msg || "#{err.inspect}"
    new(:error, params, {message: message, error: err})
  end


  def self.success(params, resp, msg=nil)
    message = msg || 'Success'
    new(:success, params, {response: resp, message: message})
  end


  # if resp inherits from Exception, then it is an error
  def self.success_or_error(params, resp, msg=nil)
    resp.class < Exception ? error(params, resp, msg) : success(params, resp, msg)
  end

end
