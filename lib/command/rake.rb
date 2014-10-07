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
          sh "rake release"
        end
        nil
      end
    end
  end
end