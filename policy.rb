policy "release-bot-1.0" do
  
  gem_managers   = role "client", "gem-managers"
  gem_publishers = role "client", "gem-publishers"
  
  gem_publishers.grant_to gem_managers
  
  resource "webservice", "rubygems" do
    permit "create", gem_publishers
    permit "delete", gem_managers
  end
  
  layer "service" do
    [ "/rubygems.org/robot@conjur.net/api-key", "/github.com/conjur-ops/private-key" ].each do |var|
      can "execute", variable(var)
    end
  end
end
