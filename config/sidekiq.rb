Sidekiq.configure_server do |config|
  redis_url = ENV['redis_url']
  config.redis = {
    url: "redis://#{redis_url}/0"
  }
end

Sidekiq.configure_client do |config|
  redis_url = ENV['redis_url']
  config.redis = {
    url: "redis://#{redis_url}/0"
  }
end
