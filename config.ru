require 'rubygems'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'conjur'
require 'releasebot'

Configuration.initialize!

require 'ws'

run WS
