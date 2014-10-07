class Configuration
  class << self
    def validate!
      require 'pathname'
      homedir = File.absolute_path("~")
      if File.directory?(File.join(homedir, ".ssh"))
        if %w(home Users).member?(Pathname.new(homedir).parent.basename.to_s)
          raise "Your HOME directory is #{homedir}, and I'm afraid to clobber your .ssh dir. Set HOME to something else!"
        end
      end
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
