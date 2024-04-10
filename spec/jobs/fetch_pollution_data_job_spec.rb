require 'rails_helper'

RSpec.describe FetchPollutionDataJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(FetchPollutionDataJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    allow(LocationService).to receive(:get_latest_location_pollution_records).and_return(true)
    allow_any_instance_of(ActiveJob::ConfiguredJob).to receive(:perform_later).and_return(true)
    job = FetchPollutionDataJob.new
    job.perform_now
    expect(LocationService).to have_received(:get_latest_location_pollution_records)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
