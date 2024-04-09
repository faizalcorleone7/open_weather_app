require_relative "./open_weather_api_base_adapter.rb"

module Adapters

  class GeologicalApiAdapter < OpenWeatherApiBaseAdapter

    def initialize(zip_code)
      @query_params = {zip: "#{zip_code},IN"}
    end

    private

    def url
      "http://api.openweathermap.org/geo/1.0/zip"
    end

    def parse_response_data(response_data)
      {
        zip: response_data["zip"],
        name: response_data["name"],
        latitude: response_data["lat"],
        longitude: response_data["lon"],
        country: response_data["country"]
      }
    end

  end

end
