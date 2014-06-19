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

  def error?
    @status == :error
  end

  def incomplete?
    @status == :incomplete
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
    message = msg || "Error: #{err}"
    new(:error, params, {message: message, error: err})
  end

  def self.incomplete(params, msg=nil)
    message = msg || "Incomplete"
    new(:incomplete, params, {message: message})
  end

  def self.success(params, resp, msg=nil)
    message = msg || 'Success'
    new(:success, params, {response: resp, message: message})
  end

end
