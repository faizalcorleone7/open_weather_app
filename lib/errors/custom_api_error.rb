#custom class for raising errors along with status codes to be sent in error responses

module Errors

  class CustomApiError < StandardError

    attr_reader :message, :code, :title

    def initialize(error_message="", error_code=500)
      super(error_message)
      @message = error_message
      @code = error_code
      @title = get_title_from_code
    end

    def code
      @code
    end

    private

    def get_title_from_code
      code_error_title_hash[code]
    end

    def code_error_title_hash
      {
        400 => "Bad Request Error",
        401 => "Unauthorized Error",
        403 => "Forbidden Error",
        404 => "Not Found Error",
        422 => "Unporcessible Entity Error",
        500 => "Internal Server Error"
      }
    end

  end

end
