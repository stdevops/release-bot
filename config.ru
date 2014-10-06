require 'rubygems'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

ENV['CONJUR_ENV'] ||= 'production'

require 'conjur/cli'
Conjur::Config.load
Conjur::Config.apply

require 'ws'

run WS
