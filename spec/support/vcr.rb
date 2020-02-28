require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!

  # Filter Rails secrets that are strings or numbers
  secrets_to_filter = Rails.application.secrets.select do |key, value|
    value.is_a?(String) || value.is_a?(Numeric)
  end
  secrets_to_filter.each do |key, value|
    c.filter_sensitive_data("<#{key.upcase}>") { value }
  end
end
