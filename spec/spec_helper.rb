require 'chefspec'
require 'chefspec/berkshelf'
require 'chefspec/cacher'
require_relative 'helpers/matchers'

# Require all our libraries
Dir['libraries/*.rb'].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.color = true
  config.log_level = :warn
  config.platform = 'debian'
  config.version = '7.4'
end

#at_exit { ChefSpec::Coverage.report! }