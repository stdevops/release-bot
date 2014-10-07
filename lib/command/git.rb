module Command
  module Git
    class Clone < Base
      include FileUtils
      
      attr_reader :repo
      
      depends :authenticate, SSH::Authenticate
      
      def initialize(repo)
        @repo = repo
      end
      
      def execute
        gemdir = repo.split('/')[-1].split('.')[0]
          
        dir = "source/#{gemdir}"
        
        rm_rf dir
        mkdir_p dir
        sh "git clone #{repo} #{dir}"
        result = nil
        cd dir do
          gemspec = Object.new.instance_eval File.read(Dir["*.gemspec"][0])
          result = [ repo, gemspec.name, dir ]
        end
        result
      end
      
    end
  end
end