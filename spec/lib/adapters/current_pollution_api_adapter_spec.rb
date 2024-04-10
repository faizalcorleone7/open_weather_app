require "#{Rails.root}/lib/adapters/current_pollution_api_adapter.rb"
require "rails_helper"

RSpec.describe Adapters::CurrentPollutionApiAdapter do

  before(:all) do
    LocationPollutionRecord.delete_all
    Location.delete_all
    stub_locations
  end

  context "Successful response" do
    it "should get data in expected format" do
      ENV['api_key'] = "sample_token_api"
      api_key = ENV['api_key']
      stub_pollution_api_responses(api_key)
      testing_obj = described_class.new(Location.first.latitude, Location.first.longitude)
      data = testing_obj.get_data
      expect(data).to eq(
        {
          :aqi=>2,
          :co=>350.48,
          :no=>0,
          :no2=>4.63,
          :ozone=>67.23,
          :so2=>11.09,
          :pm2=>nil,
          :pm10=>24.77,
          :nh3=>7.66,
          :updated_at=>"2024-04-09 04:47:56 +0530"
          }
        )
    end
  end

  context "Error response" do

    def stub_pollution_api_not_authenticated_responses(api_key=nil)
      api_key_param = api_key.present? ? "appid=#{api_key}" : ""
      Location.all.each { |location_record|
        latitude = location_record.latitude
        longitude = location_record.longitude
        stub_request(:get, "http://api.openweathermap.org/data/2.5/air_pollution?#{api_key_param}&lat=#{latitude}&lon=#{longitude}").to_return(status: 401, body: not_authenticated_response_body, headers: { 'Content-Type' => 'application/json' })
      }
    end

    def stub_pollution_api_bad_request_responses(api_key, latitude, longitude)
      latitude_param = latitude.present? ? "&lat=#{latitude}" : "&lat="
      longitude_param = longitude.present? ? "&lon=#{longitude}" : "&lon="
      stub_request(:get, "http://api.openweathermap.org/data/2.5/air_pollution?appid=#{api_key}#{latitude_param}#{longitude_param}").to_return(status: 400, body: pollution_bad_request_response_body, headers: { 'Content-Type' => 'application/json' })
    end

    it "should get not authenticated for wrong api key" do
      ENV['api_key'] = "sample_token_api"
      api_key = ENV['api_key']

      stub_pollution_api_not_authenticated_responses(api_key)
      testing_obj = described_class.new(Location.first.latitude, Location.first.longitude)
      begin
        testing_obj.get_data
      rescue => e
        expect(e.class.name).to eq("Errors::CustomApiError")
        expect(e.message).to eq("Invalid API key. Please see https://openweathermap.org/faq#error401 for more info.")
        expect(e.code).to eq(401)
        expect(e.title).to eq("Unauthorized Error")
      end
    end

    def pollution_bad_request_response_body
      {
        "cod": "400",
        "message": "Nothing to geocode"
      }.to_json
    end

    it "should get bad request for missing latitude" do
      ENV['api_key'] = "sample_token_api"
      api_key = ENV['api_key']

      location = Location.first
      location.latitude = nil
      location.save!

      stub_pollution_api_bad_request_responses(api_key, Location.first.latitude, Location.first.longitude)
      testing_obj = described_class.new(Location.first.latitude, Location.first.longitude)
      begin
        testing_obj.get_data
      rescue => e
        expect(e.class.name).to eq("Errors::CustomApiError")
        expect(e.message).to eq("Nothing to geocode")
        expect(e.code).to eq(400)
        expect(e.title).to eq("Bad Request Error")
      end
    end

    it "should get bad request for missing longitude" do
      ENV['api_key'] = "sample_token_api"
      api_key = ENV['api_key']

      location = Location.first
      location.longitude = nil
      location.save!

      stub_pollution_api_bad_request_responses(api_key, Location.first.latitude, Location.first.longitude)
      testing_obj = described_class.new(Location.first.latitude, Location.first.longitude)
      begin
        testing_obj.get_data
      rescue => e
        expect(e.class.name).to eq("Errors::CustomApiError")
        expect(e.message).to eq("Nothing to geocode")
        expect(e.code).to eq(400)
        expect(e.title).to eq("Bad Request Error")
      end
    end
  end

end
