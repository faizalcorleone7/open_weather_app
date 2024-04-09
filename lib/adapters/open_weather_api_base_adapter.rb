require_relative "./../url_helpers/request_builder.rb"

module Adapters
  class OpenWeatherApiBaseAdapter

    include UrlHelpers

    attr_reader :query_params, :url_obj

    def get_data
      build_url_object
      response_data = url_obj.get_data
      parse_response_data(response_data)
    end

    private

    def api_key
      #configure own api key, or use existing free api key
      ENV["api_key"] || "3bb390c8d09c4c89e26d039db479b7db"
    end

    def parse_response_data(response_data)
      raise "Not Implemented"
    end

    def url
      raise "Not Implemented"
    end

    def build_url_object
      request_builder = UrlHelpers::RequestBuilder.new
      request_builder.set_url(url)
      request_builder.set_api_key(api_key)
      request_builder.set_query_params(query_params)
      @url_obj = request_builder.build
    end

  end
end
