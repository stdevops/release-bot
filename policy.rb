$LOAD_PATH.unshift 'lib'
require 'releasebot'

policy "release-bot-1.1" do
  
  public_key, private_key = create_signing_key_variables 'jobs'

  aws_credentials = [ 
    variable("aws/access_key_id"), 
    variable("aws/secret_access_key")
  ]
  
  gem_managers   = role "client", "gem-managers"
  gem_publishers = role "client", "gem-publishers"

  heroku_publishers = role "client", "heroku-publishers"
  
  gem_publishers.grant_to gem_managers
  
  resource "webservice", "rubygems" do
    permit "create", gem_publishers
    permit "delete", gem_managers
  end
  
  resource "webservice", "heroku" do
    permit "create", heroku_publishers
  end
  
  layer "service" do
    Secrets.variable_ids.each do |var|
      can "execute", variable([ "", var ].join('/'))
    end
    can "read", private_key
    can_submit_job  'jobs', aws_credentials
    can_process_job 'jobs', aws_credentials
  end
end
