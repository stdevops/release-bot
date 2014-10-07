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
        mkdir_p File.expand_path("~/.ssh")
        fname = File.expand_path("~/.ssh/known_hosts")
        
        if `ssh-keygen -F #{host}`.empty?
          existing = begin
            File.read(fname)
          rescue Errno::ENOENT
            nil
          end
          File.write fname, [ existing, [ host, key ].join(" "), "" ].compact.join("\n")
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