require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
RSpec.configure do |config|
  config.include Capybara::DSL, type: :request
end
