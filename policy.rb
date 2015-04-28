$LOAD_PATH.unshift 'lib'
require 'releasebot'

# Version 2.0 uses Conjur Buildpack for SDF
policy "release-bot-2.0" do
  
  public_key, private_key = create_signing_key_variables 'jobs'

  aws_credentials = [ 
    variable("aws/access_key_id"), 
    variable("aws/secret_access_key")
  ]
  
  publishers = role "client", "publishers"
  managers   = role "client", "managers"

  publishers.grant_to managers
  
  resource "sdf", "gatekeeper" do
    permit "execute", publishers
    permit "update",  managers
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
