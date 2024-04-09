class PollutionService

  attr_reader :record

  def self.list_data(offset, limit)
    records = []
    LocationPollutionRecord.includes(:location).offset(offset).limit(limit).each { |record|
      record_data = record.as_json
      location_record = record.location

      record_data[:zip] = location_record.zip
      record_data[:name] = location_record.name
      record_data[:latitude] = location_record.latitude
      record_data[:longitude] = location_record.longitude
      record_data.delete("location_id")
      record_data.delete("created_at")
      records.push(record_data)
    }
    records
  end

  def self.create_record(location_pollution_record_data)
    LocationPollutionRecord.create!(location_pollution_record_data)
  end

  def initialize(record)
    @record = record
  end

  def update(new_data)
    return if record.updated_at == new_data[:updated_at]
    record.aqi = new_data[:aqi]
    record.co = new_data[:co]
    record.no = new_data[:no]
    record.no2 = new_data[:no2]
    record.ozone = new_data[:ozone]
    record.so2 = new_data[:so2]
    record.pm2 = new_data[:pm2]
    record.pm10 = new_data[:pm10]
    record.nh3 = new_data[:nh3]
    record.updated_at = new_data[:updated_at]
    record.save!
  end

end
