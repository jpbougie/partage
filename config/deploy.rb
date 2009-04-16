default_run_options[:pty] = true

set :port, 29209
set :use_sudo, :false

set :application, "partage"
set :repository,  "git@github.com:jpbougie/partage.git"

set :scm, "git"
set :user, "partage"
set :branch, "master"

set :deploy_to, "/var/www/#{application}"
set :config_home, "/home/partage/config"

role :app, "jpbougie.net"
role :web, "jpbougie.net"
role :db,  "jpbougie.net", :primary => true

namespace :deploy do
    task :after_symlink, :role => :app do
      run "ln -sf #{config_home}/database.yml #{current_path}/config/"
    end
    
    after :symlink, :link_configuration
    
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{try_sudo} MERB_ENV=production merb -d -a thin -e production -m #{current_path} -c 3 -P #{shared_path}/pids/partage.%s.pid"
    end
end