module Secrets
  extend self
  
  def secret? key
    env_keys.include? key.to_s.upcase
  end
  
  def variable_ids
    load_secrets
    @variable_ids
  end
  
  def env_keys
    load_secrets
    @env_keys
  end

  def lookup_secret key
    ENV[key.to_s.upcase] or raise "Secret not found in ENV : '#{key.to_s.upcase}'"
  end

  def method_missing m, *args, &block
    if args.length == 0 && secret?(m)
      lookup_secret m
    else
      super
    end
  end
  
  protected
  
  def load_secrets
    unless @env_keys
      require 'yaml'
      require 'conjur/cli'
      
      YAML.add_tag("!var", Conjur::Env::ConjurVariable)
      YAML.add_tag("!tmp", Conjur::Env::ConjurTempfile)
      definition = YAML.load(File.read('app.secrets'))
      env_keys = []
      variable_ids = []
      definition.each do |k,v|
        env_keys << k if v.is_a?(Conjur::Env::ConjurVariable)
        variable_ids << v.conjur_id if v.respond_to?(:conjur_id)
      end
      @env_keys = env_keys
      @variable_ids = variable_ids
    end
  end
end
