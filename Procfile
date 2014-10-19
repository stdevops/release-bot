web: bundle exec conjur env check -c app.secrets && bundle exec conjur env run -c app.secrets -- bundle exec rackup -p $PORT
worker: bundle exec conjur env check -c app.secrets && bundle exec conjur env run -c app.secrets -- bundle exec rake work
