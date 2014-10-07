class Configuration
  class << self
    # Perform common setup tasks.
    def initialize!
      policy_id
      service_api

      require 'pathname'
      homedir = File.absolute_path(ENV['HOME'])
      
      if File.directory?(File.join(homedir, ".ssh"))
        if %w(home Users).member?(Pathname.new(homedir).parent.basename.to_s)
          raise "Your HOME directory is #{homedir}, and I'm afraid to clobber your .ssh dir. Set HOME to something else!"
        end
      end

      Command::SSH::KnownHosts.new("github.com", "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==").perform
      Command::Rubygems::Authenticate.new(Secrets.rubygems_robot_api_key).perform
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
