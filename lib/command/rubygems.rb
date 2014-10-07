module Command
  module Rubygems
    class Authenticate < Base
      include FileUtils
      
      attr_reader :api_key, :force
      
      # Options:
      # +force+
      def initialize(api_key)
        @api_key = api_key
      end
      
      def execute
        gemdir = File.expand_path("~/.gem")
        credentials_file = File.join(gemdir, "credentials")
        $stderr.puts "Writing gem credentials to #{credentials_file}"
        mkdir_p gemdir
        File.write(credentials_file, YAML.dump({:rubygems_api_key=>api_key}))
      end
    end
    
    class Yank < Base
      include FileUtils
      
      attr_reader :repo, :version
      
      depends :clone, Git::Clone, :repo
      
      def initialize(repo, version)
        @repo = repo
        @version = version
      end
      
      def execute
        repo, gem, _ = prerequistes[:clone]
    
        sh "gem yank #{gem} -v #{version}"
      end
    end
  end
end
