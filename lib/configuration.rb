class Configuration
  class << self
    def validate!
      policy_id
      service_api
    end
    
    # Perform common setup tasks.
    def initialize!
      validate!
      
      signing_key_var = service_api.variable(SQS::Job::Policy.private_variable_name([ policy_id, 'jobs' ].join('/')))
      version_count = signing_key_var.attributes['version_count']
      raise "Signing key variable #{signing_key_var.id} has no values" if version_count.nil? || version_count == 0
      keys = [ signing_key_var.value(version_count - 1) ]
      keys << signing_key_var.value(version_count - 2) if version_count > 1
      SQS::Job.signing_keys = keys.map do |k|
        require 'slosilo'
        Slosilo::Key.new k
      end
      
      ENV['AWS_ACCESS_KEY_ID']     ||= service_api.variable([ policy_id, 'aws/access_key_id'].join('/')).value
      ENV['AWS_SECRET_ACCESS_KEY'] ||= service_api.variable([ policy_id, 'aws/secret_access_key'].join('/')).value

      Command::SSH::KnownHosts.new("github.com", "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==").perform
      Command::SSH::KnownHosts.new("heroku.com", "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAu8erSx6jh+8ztsfHwkNeFr/SZaSOcvoa8AyMpaerGIPZDB2TKNgNkMSYTLYGDK2ivsqXopo2W7dpQRBIVF80q9mNXy5tbt1WE04gbOBB26Wn2hF4bk3Tu+BNMFbvMjPbkVlC2hcFuQJdH4T2i/dtauyTpJbD/6ExHR9XYVhdhdMs0JsjP/Q5FNoWh2ff9YbZVpDQSTPvusUp4liLjPfa/i0t+2LpNCeWy8Y+V9gUlDWiyYwrfMVI0UwNCZZKHs1Unpc11/4HLitQRtvuk0Ot5qwwBxbmtvCDKZvj1aFBid71/mYdGRPYZMIxq1zgP1acePC1zfTG/lvuQ7d0Pe0kaw==").perform
    end
    
    def iam_user_name
      [ 'sys', policy_id.parameterize.gsub('-', '_') ].join("_")
    end
    
    def job_queue
      require 'aws-sdk'
      @job_queue ||= AWS::SQS.new.queues.named(job_queue_name)
    end
    
    def job_queue_name
      [ policy_id.parameterize, 'job-queue' ].join('-')
    end
    
    def policy_id
      ENV['CONJUR_POLICY_ID'] or raise "No CONJUR_POLICY_ID"
    end
    
    def service_resourceid resource
      [ "webservice", [ policy_id, resource ].join("/") ].join(":")
    end
    
    def service_login
      ENV['CONJUR_AUTHN_LOGIN'] or raise "No CONJUR_AUTHN_LOGIN"
    end
    
    def service_api_key
      ENV['CONJUR_AUTHN_API_KEY'] or raise "No CONJUR_AUTHN_API_KEY"
    end
    
    def service_api
      require 'conjur/api'

      if ENV['CONJUR_AUTHN_LOGIN']
        Conjur::API.new_from_key service_login, service_api_key
      else
        require 'conjur/cli'
        require 'conjur/authn'
        Conjur::Authn.connect
      end
    end
  end
end
