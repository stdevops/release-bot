$LOAD_PATH.unshift 'lib'
require 'releasebot'

# Version 2.0 uses Conjur Buildpack for SDF
policy "release-bot-2.0" do
  
  public_key, private_key = create_signing_key_variables 'jobs'

  aws_credentials = [ 
    variable("aws/access_key_id"), 
    variable("aws/secret_access_key")
  ]
  
  observer  = role "webservice-client", "observer"
  publisher = role "webservice-client", "publisher"
  manager   = role "webservice-client", "manager"

  # Publishers can observe
  observer.grant_to  publisher
  # Managers can publish
  publisher.grant_to manager
  
  resource "webservice" do
    permit "read",    observer
    permit "create",  publisher
    permit "update",  manager
  end
  
  layer do
    Secrets.variable_ids.each do |var|
      can "execute", variable([ "", var ].join('/'))
    end
    can "read", private_key
    can_submit_job  'jobs', aws_credentials
    can_process_job 'jobs', aws_credentials
  end
end
