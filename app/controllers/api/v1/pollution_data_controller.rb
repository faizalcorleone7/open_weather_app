module Api
  module V1
    class PollutionDataController < ApplicationController

      DEFAULT_OFFSET = 0
      private_constant :DEFAULT_OFFSET

      DEFAULT_LIMIT = 10
      private_constant :DEFAULT_LIMIT

      before_action :idempotent_fetch_data_and_initiate_jobs, only: [:list]

      def list
        offset = params[:offset] || DEFAULT_OFFSET
        limit = params[:limit] || DEFAULT_LIMIT
        render json: PollutionService.list_data(offset, limit), status: 200
      end

      private

      def idempotent_fetch_data_and_initiate_jobs
        return if LocationPollutionRecord.count.positive?
        get_all_location_pollution_records
        initiate_jobs
      end

      def get_all_location_pollution_records
        LocationService.get_latest_location_pollution_records
      end

      def initiate_jobs
        FetchPollutionDataJob.new.perform_now
      end

    end
  end
end
