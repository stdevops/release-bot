require 'rake'
require 'configuration'

module ReleaseBot
  module SSHCommands
    extend FileUtils
    extend self
    
    public
    
    def store_private_key
      ssh_dir = File.expand_path("~/.ssh")
      private_key = File.expand_path("~/.ssh/id_rsa_conjur_ops")
      
      unless File.exists?(private_key)
        mkdir_p ssh_dir
        File.write private_key, Configuration.github_conjur_ops_private_key
        chmod 0600, private_key
      end
    end
  end
end
