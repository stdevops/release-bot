require 'rubygems'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

File.umask(0)

require 'conjur'
require 'releasebot'

Configuration.initialize!
require 'raven'
require 'ws'

use Raven::Rack

run WS
