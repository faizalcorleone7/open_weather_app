require "#{Rails.root}/lib/adapters/geological_api_adapter.rb"

class LocationService

  include Adapters
  attr_reader :zip, :record

  def self.get_all_zip_codes
    Location.all.map(&:zip)
  end

  def self.get_latest_location_pollution_records
    ApplicationRecord::transaction {
      get_all_zip_codes.each { |zip|
        location_service = new(zip)
        location_service.fetch_and_update_pollution_data
      }
    }
  end

  def initialize(zip)
    @zip = zip
    @record = Location.find_by(zip: )
  end

  def record_present?
    record.present?
  end

  def create_record_from_details
    geographical_data = Adapters::GeologicalApiAdapter.new(zip).get_data
    Location.create!(geographical_data)
  end

  def fetch_and_update_pollution_data
    pollution_data = Adapters::CurrentPollutionApiAdapter.new(record.latitude, record.longitude).get_data
    location_pollution_record = record.location_pollution_record
    location_pollution_record_data = pollution_data.merge!(location_id: record.id)
    if location_pollution_record.blank?
      PollutionService.create_record(location_pollution_record_data)
    else
      PollutionService.new(location_pollution_record).update(location_pollution_record_data)
    end
  end

end
