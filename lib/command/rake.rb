module Command
  module Rake
    class Release < Base
      include FileUtils
      
      attr_reader :repo
      
      depends :clone, Git::Clone, :repo
      
      def initialize(repo)
        @repo = repo
      end
      
      def execute
        repo, gem, dir = prerequistes[:clone]
        cd dir do
          sh "git config user.email robot@conjur.net"
          sh "git config user.name  \"Conjur Releasebot\""
          sh "rake release"
        end
        nil
      end
    end
  end
end