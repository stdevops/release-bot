web: bundle exec conjur env check -c app.secrets && bundle exec conjur env run -c app.secrets -- bin/start-nginx bundle exec unicorn -c config/unicorn.rb
worker: bundle exec conjur env check -c app.secrets && bundle exec conjur env run -c app.secrets -- bundle exec rake work
