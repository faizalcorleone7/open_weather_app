require "#{Rails.root}/lib/adapters/geological_api_adapter.rb"
require "rails_helper"

RSpec.describe Adapters::GeologicalApiAdapter do
  context "Successful response" do

    def stub_geological_api_response(api_key)
      stub_request(:get, "http://api.openweathermap.org/geo/1.0/zip?appid=#{api_key}&zip=560001,IN").to_return(status: 200, body: geological_successful_response, headers: { 'Content-Type' => 'application/json' })
    end

    def geological_successful_response
      {
        "zip": "560001",
        "name": "Devanahalli taluk",
        "lat": 13.2257,
        "lon": 77.575,
        "country": "IN"
      }.to_json
    end

    it "should get location details successfully" do
      ENV['api_key'] = "sample_token_api"
      api_key = ENV['api_key']
      stub_geological_api_response(api_key)
      testing_obj = described_class.new(560001)
      data = testing_obj.get_data
      expect(data).to eq(
        {
          :zip=>"560001",
          :name=>"Devanahalli taluk",
          :latitude=>13.2257,
          :longitude=>77.575,
          :country=>"IN"
        }
      )
    end
  end

  context "Error response" do
    def stub_geological_api_not_authenticated_responses(api_key)
      stub_request(:get, "http://api.openweathermap.org/geo/1.0/zip?appid=#{api_key}&zip=560001,IN").to_return(status: 401, body: not_authenticated_response_body, headers: { 'Content-Type' => 'application/json' })
    end

    def stub_geological_api_bad_request_responses(api_key)
      stub_request(:get, "http://api.openweathermap.org/geo/1.0/zip?appid=#{api_key}&zip=,IN").to_return(status: 400, body: geological_bad_request_response_body, headers: { 'Content-Type' => 'application/json' })
    end

    def geological_bad_request_response_body
      {
        "cod": "400",
        "message": "invalid zip code"
      }.to_json
    end

    it "should get not authenticated for wrong api key" do
      ENV['api_key'] = "sample_token_api"
      api_key = ENV['api_key']

      stub_geological_api_not_authenticated_responses(api_key)
      testing_obj = described_class.new(560001)
      begin
        testing_obj.get_data
      rescue => e
        expect(e.class.name).to eq("Errors::CustomApiError")
        expect(e.message).to eq("Invalid API key. Please see https://openweathermap.org/faq#error401 for more info.")
        expect(e.code).to eq(401)
        expect(e.title).to eq("Unauthorized Error")
      end
    end

    it "should get bad request for missing zip code" do
      ENV['api_key'] = "sample_token_api"
      api_key = ENV['api_key']

      stub_geological_api_bad_request_responses(api_key)
      testing_obj = described_class.new("")
      begin
        testing_obj.get_data
      rescue => e
        expect(e.class.name).to eq("Errors::CustomApiError")
        expect(e.message).to eq("invalid zip code")
        expect(e.code).to eq(400)
        expect(e.title).to eq("Bad Request Error")
      end
    end
  end
end
