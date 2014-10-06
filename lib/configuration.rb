class Configuration
  class << self
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
    
    def rubygems_robot_api_key
      variable_value(variable_ids[:rubygems_robot_api_key])
    end
    
    def github_conjur_ops_private_key
      variable_value(variable_ids[:github_conjur_ops_private_key])
    end
    
    def variable_value variableid
      service_api.variable(variableid).value
    end
    
    def variable_ids
      {
        rubygems_robot_api_key: "rubygems.org/robot@conjur.net/api-key",
        github_conjur_ops_private_key: "github.com/conjur-ops/private-key"
      }
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