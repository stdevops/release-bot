module Command
  module Rake
    class Release < Base
      include FileUtils
      
      attr_reader :repo, :dir
      
      depends :clone, Git::Clone, :repo, lambda {|result|
        @dir = result[2]
      }
      depends :authenticate, Rubygems::Authenticate
      depends :git_config, Git::Config, :dir
      
      def initialize(repo)
        @repo = repo
      end
      
      def execute
        cd dir do
          sh "rake release"
        end
        nil
      end
    end
  end
end