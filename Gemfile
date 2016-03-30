source 'https://rubygems.org'

gem 'rake', '~> 10.5.0'
gem 'conjur-api', github: 'conjurinc/api-ruby', branch: 'master'
gem 'conjur-sinatra', github: 'conjurinc/conjur-sinatra', branch: 'master'
gem 'activesupport'
gem 'sinatra'
gem 'conjur-cli', github: 'conjurinc/cli-ruby', branch: 'master'
gem 'conjur-asset-audit-send', github: 'conjurinc/conjur-asset-audit-send', branch: 'master'
gem 'sqs-job', github: 'conjurinc/sqs-job', branch: 'master'
gem 'aws-sdk', '< 2'
gem 'yard'
gem 'net-ssh'
gem 'unicorn'
gem 'netrc'
gem 'heroku'
gem 'sentry-raven', '~> 0.12.3'

group :test, :development do
  gem 'rspec'
  gem "rack-test", require: "rack/test"
  gem 'ci_reporter_rspec'
  gem 'webmock'
  gem 'conjur-asset-ui'
  gem 'pry'
end

