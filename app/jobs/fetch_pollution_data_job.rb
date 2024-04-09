class FetchPollutionDataJob < ApplicationJob
  include Adapters
  queue_as :default

  after_perform do |job|
    self.class.set(:wait => time_interval).perform_later
  end

  def perform
    LocationService.get_latest_location_pollution_records
  end

  private

  def time_interval
    #either configure time interval or it is set to 30 seconds by default
    (ENV["job_interval"].to_i || 30).seconds
  end

end
