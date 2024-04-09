require_relative "./open_weather_api_base_adapter.rb"

module Adapters

  class CurrentPollutionApiAdapter < OpenWeatherApiBaseAdapter

    def initialize(latitude, longitude)
      @query_params = {
        lat: latitude,
        lon: longitude
      }
    end

    private

    def url
      "http://api.openweathermap.org/data/2.5/air_pollution"
    end

    def parse_response_data(response_data)
      current_pollutant_data = response_data["list"].first
      pollutant_component_data = current_pollutant_data["components"]
      {
        aqi: current_pollutant_data["main"]["aqi"],
        co: pollutant_component_data["co"],
        no: pollutant_component_data["no"],
        no2: pollutant_component_data["no2"],
        ozone: pollutant_component_data["o3"],
        so2: pollutant_component_data["so2"],
        pm2: pollutant_component_data["pm2"],
        pm10: pollutant_component_data["pm10"],
        nh3: pollutant_component_data["nh3"],
        updated_at: Time.at(current_pollutant_data["dt"]).to_s
      }
    end

  end

end
