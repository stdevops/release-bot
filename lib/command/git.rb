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
          gem_name = nil
          if gemspec = Dir["*.gemspec"][0]
            gem_name = Object.new.instance_eval(File.read(gemspec)).name
          end
          result = [ repo, gem_name, dir ]
        end
        result
      end
    end
    
    class Config < Base
      include FileUtils
      
      attr_reader :dir
      
      def initialize(dir)
        @dir = dir
      end
      
      def execute
        cd dir do
          require 'shellwords'
          sh %Q(git config user.email "#{Secrets.git_user_email}")
          sh %Q(git config user.name  "#{Secrets.git_user_name}")
        end
      end
    end
  end
end