# Load the Rails application.
require File.expand_path('../application', __FILE__)

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
#    Sidekiq.redis { |r| r.client.reconnect } if forked
  end
end

# Initialize the Rails application.
Rails.application.initialize!
