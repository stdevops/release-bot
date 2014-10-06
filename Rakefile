$LOAD_PATH.unshift 'lib'

namespace :gem do
  task :gem_commands do
    require 'releasebot/gem_commands'
    include ReleaseBot
  end
  
  task :release, [:repo] => :gem_commands do |t,args|
    GemCommands.release args[:repo]
  end
  
  task :yank, [:repo, :version] => :gem_commands do |t,args|
    GemCommands.yank args[:repo], args[:version]
  end
end
