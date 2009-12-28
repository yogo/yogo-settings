require 'rubygems'
require 'dm-core'

require File.dirname(__FILE__) + '/../lib/yogo_settings'

Yogo::Settings.load_defaults(File.dirname(__FILE__)+'/test_settings.yml')

DataMapper.setup(:default, 'sqlite3:memory')

