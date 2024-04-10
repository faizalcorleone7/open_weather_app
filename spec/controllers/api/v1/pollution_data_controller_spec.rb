require "rails_helper"
require "json"
require 'webmock/rspec'

describe Api::V1::PollutionDataController do
  before(:all) do
    LocationPollutionRecord.delete_all
    Location.delete_all


    stub_locations
  end

  context "get location pollution data first time" do
    it "should get all the location and initiate jobs" do
      ENV["api_key"] = "sample_api_key"
      stub_pollution_api_responses("sample_api_key")
      allow_any_instance_of(ActiveJob::ConfiguredJob).to receive(:perform_later).and_return(true)
      get :list
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      pollution_records = LocationPollutionRecord.offset(0).limit(10)
      response_body.each_with_index { |data_row, index|
        pollution_record = pollution_records[index]
        location = pollution_record.location
        compare_data_row_pollution_record_and_location(data_row, pollution_record, location)
      }
    end
  end

  context "get latest location pollution data" do
    def stub_pollution_data
      location_pollution_file = File.open("#{Rails.root}/spec/fixtures/files/location_pollution_data.json")
      location_pollution_data = JSON.load(location_pollution_file)
      Location.all.order(:id).each_with_index { |location, index|
        location_pollution_record = location_pollution_data[index]
        location_pollution_record[:updated_at] = Time.now
        location_pollution_record[:location_id] = location.id
        LocationPollutionRecord.create!(location_pollution_record)
      }
    end

    before(:all) do
      LocationPollutionRecord.delete_all
      stub_pollution_data
    end

    it "should get location data if no offset is passed" do
      get :list, params: {limit: 5}
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      pollution_records = LocationPollutionRecord.limit(5)
      response_body.each_with_index { |data_row, index|
        pollution_record = pollution_records[index]
        location = pollution_record.location
        compare_data_row_pollution_record_and_location(data_row, pollution_record, location)
      }
    end

    it "should get location data if no limit is passed" do
      get :list, params: {offset: 2}
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      data_row = response_body.first
      pollution_record = LocationPollutionRecord.offset(2).first
      location = pollution_record.location
      compare_data_row_pollution_record_and_location(data_row, pollution_record, location)
    end

    it "should get location data if no offset and no limit are passed" do
      get :list
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      pollution_records = LocationPollutionRecord.offset(0).limit(10)
      response_body.each_with_index { |data_row, index|
        pollution_record = pollution_records[index]
        location = pollution_record.location
        compare_data_row_pollution_record_and_location(data_row, pollution_record, location)
      }
    end

    it "should get location data if offset and limit are passed" do
      get :list, params: {limit: 3, offset: 1}
      response_body = JSON.parse(response.body)
      pollution_records = LocationPollutionRecord.offset(1).limit(3)
      response_body.each_with_index { |data_row, index|
        pollution_record = pollution_records[index]
        location = pollution_record.location
        compare_data_row_pollution_record_and_location(data_row, pollution_record, location)
      }
    end
  end
end
