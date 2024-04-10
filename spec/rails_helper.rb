# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

def stub_locations
  location_file = File.open("#{Rails.root}/spec/fixtures/files/location.json")
  location_data = JSON.load(location_file)
  Location.create!(location_data)
  location_file.close
end

def compare_data_row_pollution_record_and_location(data_row, pollution_record, location)
  expect(data_row["id"]).to eq(pollution_record.id)
  expect(data_row["aqi"]).to eq(pollution_record.aqi)
  expect(data_row["co"]).to eq(pollution_record.co)
  expect(data_row["no"]).to eq(pollution_record.no)
  expect(data_row["no2"]).to eq(pollution_record.no2)
  expect(data_row["ozone"]).to eq(pollution_record.ozone)
  expect(data_row["so2"]).to eq(pollution_record.so2)
  expect(data_row["pm2"]).to eq(pollution_record.pm2)
  expect(data_row["pm10"]).to eq(pollution_record.pm10)

  expect(location["zip"]).to eq(location.zip)
  expect(location["name"]).to eq(location.name)
  expect(location["latitude"]).to eq(location.latitude)
  expect(location["longitude"]).to eq(location.longitude)
end

def stub_pollution_api_responses(api_key)
  Location.all.each { |location_record|
    latitude = location_record.latitude
    longitude = location_record.longitude
    stub_request(:get, "http://api.openweathermap.org/data/2.5/air_pollution?appid=#{api_key}&lat=#{latitude}&lon=#{longitude}").to_return(status: 200, body: pollution_response_body(latitude, longitude), headers: { 'Content-Type' => 'application/json' })
  }
end

def pollution_response_body(latitude, longitude)
  {
    "coord": {
      "lon": longitude,
      "lat": latitude
    },
    "list": [
      {
        "main": {
          "aqi": 2
        },
        "components": {
          "co": 350.48,
          "no": 0,
          "no2": 4.63,
          "o3": 67.23,
          "so2": 11.09,
          "pm2_5": 19.4,
          "pm10": 24.77,
          "nh3": 7.66
        },
        "dt": 1712618276
      }
    ]
  }.to_json
end

def not_authenticated_response_body
  {
    "cod": 401,
    "message": "Invalid API key. Please see https://openweathermap.org/faq#error401 for more info."
  }.to_json
end
