module SQS::Job::Message
  class HerokuRelease < Base
    HEROKU_REPOS = [
      Command::Heroku::App.new("developer-www-conjur", "git@github.com:conjurinc/developer-www.git", "rails", "deploy.sh"),
      Command::Heroku::App.new("trial-factory-conjur", "git@github.com:conjurinc/trial-factory.git")
    ].inject({}){|memo,app| memo[app.name] = app; memo}
    
    validates_presence_of :name, :client_roleid
    
    def name; params[:name]; end
    def client_roleid; params[:client_roleid]; end
    
    def invoke!
      app = HEROKU_REPOS[name] or raise "Heroku app #{name} not found"
      Command::Heroku::Release.new(app).perform
    
      Configuration.service_api.audit_send params.merge({
        "facility" => "releasebot",
        "action" => "release",
        "app_name" => app.name,
        "repo" => app.repo,
        "client" => client_roleid,
        "resources" => [ Configuration.service_resourceid("heroku") ],
        "roles" => [ client_roleid ],
        "remote_ip" => request.ip
      })
    end
  end
end