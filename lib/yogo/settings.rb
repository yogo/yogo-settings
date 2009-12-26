# Yogo Settings Module
# Copyright (c) 2009 Montana State University
#
# FILE: settings.rb
# Implementing a settings configuration class.
class Yogo::Settings
  include DataMapper::Resource  

  storage_names[:default] = 'yogo_settings'
  storage_names[:yogo_settings_cache] = 'yogo_settings'

  # property :id,    Serial
  property :name,   String, :key => true
  property :value,   String
  
  DataMapper.setup(:yogo_settings_cache, 'sqlite3::memory:')
  repository(:yogo_settings_cache) { Yogo::Settings.auto_migrate! }
  
  self.auto_migrate! unless self.storage_exists?(:default)
  
  @@default_settings = {}
  @@loaded_defaults = false
  
  def self.[](key)
    response = check_cache(key) 
    if response.nil?
      response = check_database(key)
      response = check_defaults(key) if response.nil?
      store_cache(key, response.value) unless response.nil?
    end

    unless response.nil?
      return true  if response.value.eql?('true')
      return false if response.value.eql?('false')
      return response.value 
    end
  end
  
  def self.[]=(key,value)
    self.store_cache(key,value)
    self.store_database(key,value)
  end
  
  private
  
  def self.check_cache(key)
    # puts "Checking cache for #{key}"
    repository(:yogo_settings_cache) { self.get(key) }
  end
  
  def self.check_defaults(key)
    # puts "Checking defaults for #{key}"
    key = key.to_s if key.is_a? Symbol
    if !@@loaded_defaults
      settings_files = Dir.glob(Rails.root.to_s+"/vendor/gems/**/config/settings.yml") # Gem settings
      settings_files << Dir.glob(Rails.root.to_s+"/vendor/plugins/**/config/settings.yml") # plugin settings
      settings_files << Dir.glob(Rails.root.to_s+"/config/settings.yml") # App settings
      settings_files.flatten!
    
    
      settings_files.each{ |file|
        config = YAML.load_file(file)
        @@default_settings.merge!(config) unless config == false
      }

      @@loaded_defaults = true
    end

    return self.new(:name => key, :value => @@default_settings[key]) if @@default_settings.has_key?(key)
  end
  
  def self.check_database(key)   
    # puts "Checking database for #{key}"
    repository(:default) { self.get(key) }
  end
  
  def self.store_cache(key, value)
    # puts "Storing #{key} in cache"
    self.store(key, value, :yogo_settings_cache)
  end
  
  def self.store_database(key,value)
    # puts "Storing #{key} in database"
    self.store(key, value, :default)
  end
  
  def self.store(key, value, storage_name)
    repository(storage_name) do
      record = self.get(key) || self.new(:name => key)
      record.value = value
      record.save
    end
  end
  
end