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
    "conjur-asset-proxy" => "conjurinc/conjur-asset-proxy"
  }
  
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
    Command::SSH::KnownHosts.new("github.com", "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==").perform
    Command::Rake::Release.new(repo).perform

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
    Command::Gems::Yank.new(repo, version).perform

    status 200
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
