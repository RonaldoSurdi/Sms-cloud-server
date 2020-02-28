if defined? Rack::Timeout
  Rack::Timeout.timeout = Integer(ENV['RACK_TIMEOUT'] || 20) # seconds
end
