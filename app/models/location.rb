class Location < ApplicationRecord
  has_one :location_pollution_record, class_name: "LocationPollutionRecord", foreign_key: "location_id"
end
