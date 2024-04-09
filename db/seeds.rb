# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

location_count = ENV["location_count"].to_i
unless Location.count >= location_count
  start_zip_code = 560001
  zip_code = start_zip_code
  count = 0
  while true
    location_obj = LocationService.new(zip_code)
    zip_code = zip_code + 1
    if location_obj.record_present?
      count = count + 1
      break if count == location_count
    end

    location_obj.create_record_from_details rescue next
    count = count + 1
    break if count == location_count
  end
end
