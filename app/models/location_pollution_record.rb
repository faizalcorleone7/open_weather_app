class LocationPollutionRecord < ApplicationRecord
  self.table_name = :location_pollution_data
  belongs_to :location, class_name: "Location", foreign_key: "location_id"
end
