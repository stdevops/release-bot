require 'rake'
require 'releasebot/ssh_commands'

module ReleaseBot
  module GemCommands
    extend FileUtils
    extend self
    
    public 
    
    def release repo
      repo, gem, dir = git_clone repo
      cd dir do
        sh "rake release"
      end
    end
    
    def yank repo, version
      repo, gem, dir = git_clone repo
  
      sh "gem yank #{gem} -v #{version}"
    end
    
    protected
    
    def git_clone repo
      SSHCommands.store_private_key
    
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