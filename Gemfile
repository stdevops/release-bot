source 'https://rubygems.org'

gem 'rake'
gem 'conjur-api', github: 'conjurinc/api-ruby',  branch: 'master'
gem 'conjur-sinatra', github: 'conjurinc/conjur-sinatra', branch: 'master'
gem 'activesupport'
gem 'sinatra'
gem 'conjur-cli', github: 'conjurinc/cli-ruby',  branch: 'master'
gem 'conjur-asset-audit-send', github: 'conjurinc/conjur-asset-audit-send', branch: 'master'
gem 'yard'
gem 'net-ssh'

group :test, :development do
  gem 'rspec', '>= 2.14', '< 3.0'
  gem 'cucumber'
  gem 'capybara'
  gem 'json_spec'
  gem 'cucumber-sinatra'
  gem "rack-test", require: "rack/test"
  gem 'ci_reporter_rspec'
  gem 'webmock'
  gem 'conjur-asset-ui'
  gem 'pry'
end

