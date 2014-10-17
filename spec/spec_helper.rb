$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'rspec'
require 'webmock'
require 'releasebot'

WebMock.disable_net_connect!