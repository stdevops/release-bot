module Command
  module Rubygems
    class Authenticate < Base
      include FileUtils
      
      def execute
        require 'fileutils'
        gemdir = File.expand_path("~/.gem")
        credentials_file = File.join(gemdir, "credentials")
        $stderr.puts "Writing gem credentials to #{credentials_file}"
        mkdir_p gemdir
        File.write(credentials_file, YAML.dump({:rubygems_api_key=>Secrets.rubygems_api_key}))
        FileUtils.chmod 0600, credentials_file
      end
    end
    
    class Yank < Base
      include FileUtils
      
      attr_reader :repo, :version
      
      depends :clone, Git::Clone, :repo
      depends :authenticate, Authenticate
      
      def initialize(repo, version)
        @repo = repo
        @version = version
      end
      
      def execute
        _, gem, _ = prerequistes[:clone]
    
        sh "gem yank #{gem} -v #{version}"
      end
    end
  end
end
