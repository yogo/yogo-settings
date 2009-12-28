require 'rubygems'
require 'dm-core'

require File.dirname(__FILE__) + '/../lib/yogo_settings'

DataMapper.setup(:default, 'sqlite3:memory')

