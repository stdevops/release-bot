require 'active_support'
require 'active_support/core_ext'
require 'secrets'
require 'configuration'
require 'commands'
require 'conjur/cli'
require 'conjur-asset-audit-send'

Configuration.validate!
Configuration.initialize!

Conjur::Config.load
Conjur::Config.apply
