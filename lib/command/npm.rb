module Command
  module NPM
    class Authenticate < Base
      include FileUtils
      
      def execute
        require 'fileutils'
        credentials_file = File.expand_path("~/.npmrc")
        dont_clobber credentials_file do
          $stderr.puts "Writing npm credentials to #{credentials_file}"
          File.write credentials_file, <<-CREDENTIALS
_auth=#{Secrets.npm_api_key}
email=#{Secrets.npm_email}
CREDENTIALS
          FileUtils.chmod 0600, credentials_file
        end
      end
    end
    
    class Publish < Base
      include FileUtils
      
      attr_reader :repo
      attr_accessor :branch
      
      depends Authenticate
      depends Git::Clone, :repo, :branch      
      
      def initialize(repo)
        @repo = repo
      end
      
      def execute
        _, _, dir = prerequistes[Git::Clone]
        cd dir do
          sh "npm publish"
        end
      end
    end
  end
end
