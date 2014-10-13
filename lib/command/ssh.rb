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
        
        if `ssh-keygen -F #{host} -f #{fname}`.empty?
          $stderr.puts "Adding #{host} to #{fname}"
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
        key_file = File.expand_path("~/.ssh/id_rsa")
        key = Secrets.ssh_private_key
        
        if !File.exists?(key_file) || File.read(key_file) != key
          $stderr.puts "Writing private key file #{key_file}"
          mkdir_p ssh_dir
          File.write key_file, key
          chmod 0600, key_file
        end

        nil
      end
    end
  end
end