module Command
  module Heroku
    App = Struct.new(:name, :repo, :branch, :script) do
      def branch; self[:branch] || 'master'; end
    end
    
    class Login < Base
      def execute
        require 'netrc'
        netrc = Netrc.read
        netrc['api.heroku.com'] = Secrets.heroku_email, Secrets.heroku_api_key
        netrc['git.heroku.com'] = Secrets.heroku_email, Secrets.heroku_api_key
        netrc.save
      end
    end
    
    class Release < Base
      include FileUtils
      
      attr_reader :app, :dir, :repo
      
      depends Git::Clone, :repo, lambda {|result|
        @dir = result[2]
      }
      depends Login
      depends Git::Config, :dir
      
      def initialize(app)
        @app = app
        @repo = app.repo
      end
      
      def execute
        repo, gem, dir = prerequistes[Git::Clone]
        cd dir do
          sh "git remote add heroku git@heroku.com:#{app.name}.git"
          sh "git push heroku refs/heads/#{app.branch}:master"
          if app.script
            sh "./#{app.script}"
          end
        end
        nil
      end
    end
  end
end