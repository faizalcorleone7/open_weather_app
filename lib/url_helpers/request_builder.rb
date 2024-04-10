require_relative "./request_executor.rb"

module UrlHelpers
  class RequestBuilder

    attr_reader :url, :api_key, :params, :request_executor

    def set_url(url)
      @url = url
    end

    def set_api_key(api_key)
      @api_key = api_key
    end

    def set_query_params(params_hash)
      @params = params_hash
    end

    def build
      @request_executor = RequestExecutor.new(construct_url)
    end

    def get_url_obj
      request_executor
    end

    private

    def construct_url
      "#{url}?#{derive_query_params}&appid=#{api_key}"
    end

    def derive_query_params
      query_string = ""
      params.each { |param, value|
        query_string = query_string + "#{query_string.blank? ? "" : "&"}#{param}=#{value}"
      }
      query_string
    end

  end
end
