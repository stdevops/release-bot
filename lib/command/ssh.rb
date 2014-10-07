module Command
  module SSH
    class Authenticate < Base
      include FileUtils
      
      def execute
        ssh_dir = File.expand_path("~/.ssh")
        private_key = File.expand_path("~/.ssh/id_rsa_conjur_ops")
        
        unless File.exists?(private_key)
          mkdir_p ssh_dir
          File.write private_key, Secrets.github_conjur_ops_private_key
          chmod 0600, private_key
        end
        nil
      end
    end
  end
end