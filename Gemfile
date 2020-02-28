source 'https://rubygems.org'
ruby '2.2.1'

gem 'rails',                  '4.1.8'
gem 'puma',                   '2.11.1'
gem 'sass-rails'
gem 'uglifier',               '2.5.3'
gem 'coffee-rails',           '4.1.0'
gem 'jquery-rails',           '3.1.2'
gem 'turbolinks',             '2.5.2'
gem 'jbuilder',               '2.2.5'
gem 'rake',                   '10.5.0'
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'pg'

gem "devise"
gem "foreigner"
gem "brazilian-rails"
gem "date_validator"
gem "paperclip"
gem "cancancan"
#gem "baseinocode-rails", git: "https://inocode@bitbucket.org/inocode/baseinocode-rails.git"
gem "baseinocode-rails", path: "/var/www/baseinocode-rails/"
gem 'simple_form',            '3.1.0'
gem "js-routes"
gem 'missing_validators'
gem "gcm"
gem "enumerate_it"
gem "squeel", "1.2.3"
gem "pagseguro-oficial", "2.1.1"
gem "zenvia-sms"
gem "correios-cep", "0.6.4"

# Scheduling jobs
gem "clockwork"
gem "daemons"

#Assets
gem "compass-rails", '~> 2.0.2'
gem "kaminari-bootstrap"
gem "clean_pagination"
gem "dropzonejs-rails"
gem 'spinjs-rails'
gem "bootstrap-sass", '~> 3.3.3'
gem "font-awesome-rails"

group :production, :staging do
  gem "rack-timeout"
  gem "unicorn"
end

group :development do
  gem 'spring',               '1.2.0'
  gem 'letter_opener',        '1.2.0'
  gem 'bullet',               '4.14.0'
  gem 'quiet_assets',         '1.0.3'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'guard-livereload',     require: false
  gem 'guard-rspec',          require: false
  gem 'derailed'
end

group :test do
  gem 'shoulda-matchers',     '2.8.0', require: false
  gem 'simplecov',            '0.9.1', require: false
  gem 'email_spec',           '1.6.0'
  gem 'capybara',             '2.4.4'
  gem 'poltergeist',          '1.5.1'
  gem 'vcr',                  '2.9.3'
  gem 'webmock',              '1.20.4'
  gem 'database_cleaner',     '1.3.0'
  gem "rubycritic",                    require: false, git: "https://github.com/whitesmith/rubycritic"
end

group :development, :test do
  gem 'rspec-rails',          '3.1.0'
  gem 'factory_girl_rails',   '4.5.0'
  gem 'pry-rails',            '0.3.4'
  gem 'dotenv-rails',         '1.0.2'
  gem 'awesome_print',        '1.2.0'
  gem 'faker'
  gem 'timecop'
end
