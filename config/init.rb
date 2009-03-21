# Go to http://wiki.merbivore.com/pages/init-rb
 
require 'config/dependencies.rb'
 
use_orm :datamapper
use_test :rspec
use_template_engine :erb
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'memcache'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = 'c81b212ccf1f7b5fbd0568ef195ea4c23d4f2669'  # required for cookie session store
  c[:session_id_key] = '_partage_session_id' # cookie session id key, defaults to "_session_id"
  
  c[:upload_dir] = Merb.root / "uploads"
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  require 'ftools'
  (0..255).each {|n|
    File.makedirs(Merb::Config[:upload_dir] / "%02x" % n)
  }
  
  require 'memcache'
  Merb::MemcacheSession.store = 
     Memcached.new('127.0.0.1:11211', :namespace => 'partage')
end
