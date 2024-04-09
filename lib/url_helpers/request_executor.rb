require 'httparty'
require_relative "./../errors/custom_api_error.rb"

module UrlHelpers
  class RequestExecutor

    include Errors

    attr_reader :url_string

    def initialize(url_string)
      @url_string = url_string
    end

    def get_data
      response = HTTParty.get(url_string)
      if response.code != 200
        error_message = get_error_message(response)
        raise CustomApiError.new(error_message, response.code)
      end
      response.parsed_response
    end

    private

    def get_error_message(response)
      response["message"]
    end

  end
end
