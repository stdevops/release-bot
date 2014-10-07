module Command
  module Gems
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
