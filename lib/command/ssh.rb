module Command
  module SSH
    class KnownHosts < Base
      include FileUtils
      
      attr_reader :host, :key
      
      def initialize(host, key)
        @host = host
        @key = key
      end
      
      def execute
        known_hosts = []
        fname = File.expand_path("~/.ssh/known_hosts")
        if File.exists?(fname)
          known_hosts = File.read(fname).split("\n")
        end
        unless known_hosts.find{|l| l =~ %r(^#{host}\s)}
          known_hosts << [ host, key ].join(" ")
          File.write fname, known_hosts.join("\n")
        end
        nil
      end
    end
    
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