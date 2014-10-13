require 'sinatra/base'
require 'conjur/api'
require 'conjur/sinatra'

class WS < ::Sinatra::Base
  extend Conjur::Sinatra

  enable :dump_errors, :raise_errors
  
  helpers do
    def authorize! service, privilege
      conjur_client_api.current_role.permitted?(Configuration.service_resourceid(service), privilege) or halt(403, "Unauthorized")
    end
  end
  
  GEM_REPOS = {
    "conjur-api" => "conjurinc/api-ruby",
    "conjur-cli" => "conjurinc/cli-ruby",
    "conjur-asset-ui" => "conjurinc/conjur-asset-ui",
    "conjur-asset-audit-send" => "conjurinc/conjur-asset-audit-send",
    "conjur-asset-host-factory" => "conjurinc/conjur-asset-host-factory",
    "conjur-asset-proxy" => "conjurinc/conjur-asset-proxy",
    "slosilo" => "conjurinc/slosilo"
  }
  
  HEROKU_REPOS = [
    Command::Heroku::App.new("developer-www-ci-conjur", "git@github.com:conjurinc/developer-www.git", "rails", "deploy.sh"),
    Command::Heroku::App.new("developer-www-conjur", "git@github.com:conjurinc/developer-www.git", "rails", "deploy.sh"),
    Command::Heroku::App.new("trial-factory-conjur", "git@github.com:conjurinc/trial-factory.git")
  ].inject({}){|memo,app| memo[app.name] = app; memo}
  
  # Release a gem.
  # +create+ permission is required on 'rubygems'.
  #
  # Request parameters:
  #
  # +name+ gem name, which must be found in GEM_REPOS whitelist
  post '/rubygems/releases' do
    authorize! "rubygems", :create

    name = param!(:name)
    repo = GEM_REPOS[name] or halt 500, "Gem #{name} not found"
    repo = "git@github.com:#{repo}.git"
    Command::Rake::Release.new(repo).perform

    Configuration.service_api.audit_send params.merge({
      "facility" => "releasebot",
      "action" => "release",
      "gem_name" => name,
      "repo" => repo,
      "client" => conjur_client_api.current_role.roleid,
      "resources" => [ Configuration.service_resourceid("rubygems") ],
      "roles" => [ conjur_client_api.current_role.roleid ],
      "remote_ip" => request.ip
    })

    status 201
  end
  
  # Yank a gem release.
  # +delete+ permission is required on 'rubygems'.
  #
  # In addition to the gem name, a +version+ parameter is required.
  delete '/rubygems/releases/:name' do
    authorize! "rubygems", :delete

    name = params[:name]
    version = param! :version
    repo = GEM_REPOS[name] or halt 500, "Gem #{name} not found"
    repo = "git@github.com:#{repo}.git"
    Command::Rubygems::Yank.new(repo, version).perform

    Configuration.service_api.audit_send params.merge({
      "facility" => "releasebot",
      "action" => "yank",
      "gem_name" => name,
      "repo" => repo,
      "gem_version" => version,
      "client" => conjur_client_api.current_role.roleid,
      "resources" => [ Configuration.service_resourceid("rubygems") ],
      "roles" => [ conjur_client_api.current_role.roleid ],
      "remote_ip" => request.ip
    })
    
    status 200
  end
  
  # Release to Heroku.
  # +create+ permission is required on 'heroku'.
  #
  # Request parameters:
  #
  # +name+ gem name, which must be found in GEM_REPOS whitelist
  post '/heroku/releases' do
    authorize! "heroku", :create
  
    name = param!(:name)
    app = HEROKU_REPOS[name] or halt 500, "Heroku app #{name} not found"
    Command::Heroku::Release.new(app).perform
  
    Configuration.service_api.audit_send params.merge({
      "facility" => "releasebot",
      "action" => "release",
      "app_name" => app.name,
      "repo" => app.repo,
      "client" => conjur_client_api.current_role.roleid,
      "resources" => [ Configuration.service_resourceid("heroku") ],
      "roles" => [ conjur_client_api.current_role.roleid ],
      "remote_ip" => request.ip
    })
  
    status 201
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
