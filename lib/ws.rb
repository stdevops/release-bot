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
  
  NPM_REPOS = {
    "conjur-api" => "conjurinc/api-node",
  }
  
  GEM_REPOS = {
    "conjur-api" => "conjurinc/api-ruby",
    "conjur-cli" => "conjurinc/cli-ruby",
    "conjur-asset-ui" => "conjurinc/conjur-asset-ui",
    "conjur-asset-audit-send" => "conjurinc/conjur-asset-audit-send",
    "conjur-asset-host-factory" => "conjurinc/conjur-asset-host-factory",
    "conjur-asset-aws" => "conjurinc/conjur-asset-aws",
    "conjur-asset-proxy" => "conjurinc/conjur-asset-proxy",
    "slosilo" => "conjurinc/slosilo",
    "conjur-rack" => "conjurinc/conjur-rack"
  }
  
  # Release an NPM package.
  # +create+ permission is required on 'npm'.
  #
  # Request parameters:
  #
  # +name+ package name, which must be found in NPM_REPOS whitelist
  post '/npm/releases' do
    authorize! "npm", :create

    name = param!(:name)
    repo = NPM_REPOS[name] or halt 500, "Node package #{name} not found"
    repo = "git@github.com:#{repo}.git"
    publish = Command::NPM::Publish.new(repo)
    publish.branch = params[:branch] if params[:branch]
    publish.perform

    Configuration.service_api.audit_send params.merge({
      "facility" => "releasebot",
      "action" => "npm/releases",
      "package_name" => name,
      "repo" => repo,
      "client" => conjur_client_api.current_role.roleid,
      "resources" => [ Configuration.service_resourceid("npm") ],
      "roles" => [ conjur_client_api.current_role.roleid ],
      "remote_ip" => request.ip
    })

    status 201
  end
  
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
    release = Command::Rake::Release.new(repo)
    release.branch = params[:branch] if params[:branch]
    release.perform

    Configuration.service_api.audit_send params.merge({
      "facility" => "releasebot",
      "action" => "rake/release",
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
      "action" => "rubygems/yank",
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
    
    require 'sqs/job/message/heroku_release'
  
    name = param!(:name)
    halt 500, "Heroku app #{name} not found" unless SQS::Job::Message::HerokuRelease::HEROKU_REPOS[name]
    
    SQS::Job.send_message Configuration.job_queue, 'heroku_release', { name: name, client_roleid: conjur_client_api.current_role.roleid }
  
    status 201
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
