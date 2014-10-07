require 'rubygems'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

ENV['CONJUR_ENV'] ||= 'production'

require 'releasebot'

require 'ws'

run WS
