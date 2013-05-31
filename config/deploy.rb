set :application, "missionfig"
set :repository,  "git@github.com:lognllc/missionfig.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

task :development do 
  role :app, "missionfig2.lognllc.com"                          # This may be the same as your `Web` server
  set :user, "ubuntu"
  #role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
  #role :db,  "your slave db-server here"

  set :deploy_to, "/home/ubuntu/www/missionfig"
  set :deploy_subdir, 'Server/missionfig_game'

  # if you want to clean up old releases on each deploy uncomment this:
  # after "deploy:restart", "deploy:cleanup"
  #after 'deploy:update', 'bundle:install', 'deploy:migrate'

  after "deploy:restart","deploy:update_swf"
  after "deploy:update_swf", "deploy:restore_assets"
  before :deploy, "deploy:backup_assets"
end

task :stage do
  role :app, "gamestaging.projectmfig.com"        # This may be the same as your `Web` server
  set :user, "ubuntu"
  #role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
  #role :db,  "your slave db-server here"

  set :deploy_to, "/home/ubuntu/www/missionfig"
  set :deploy_subdir, 'Server/missionfig_game'

  # if you want to clean up old releases on each deploy uncomment this:
  # after "deploy:restart", "deploy:cleanup"
  #after 'deploy:update', 'bundle:install', 'deploy:migrate'

  after "deploy:restart","deploy:update_swf"
  after "deploy:update_swf", "deploy:restore_assets"
  after :deploy, "deploy:restart"
end

task :production do 
  role :app, "ec2-107-21-130-107.compute-1.amazonaws.com"        # This may be the same as your `Web` server
  set :user, "ubuntu"
  #role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
  #role :db,  "your slave db-server here"

  set :deploy_to, "/home/ubuntu/www/missionfig"
  set :deploy_subdir, 'Server/missionfig_game'

  # if you want to clean up old releases on each deploy uncomment this:
  # after "deploy:restart", "deploy:cleanup"
  #after 'deploy:update', 'bundle:install', 'deploy:migrate'

 
  after "deploy:restart","deploy:update_swf"
  after "deploy:update_swf", "deploy:restore_assets"
  before :deploy, "deploy:backup_assets"
end


namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab do
    run "cd #{deploy_to}/current && whenever --update-crontab #{application}"
  end

  task :update_swf do
    run "cp --remove-destination #{deploy_to}/shared/cached-copy/Flash/bin-debug/*.swf #{deploy_to}/current/public/."
  end

  task :restart do
    run "sudo /etc/init.d/apache2 restart"
  end

  task :backup_assets do
    run "cp -rf #{deploy_to}/current/app/assets/images/* /home/ubuntu/missionfig/backup_images/."
  end

  task :restore_assets do
    run "cp -rf /home/ubuntu/missionfig/backup_images/* #{deploy_to}/current/app/assets/images/."
  end

end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
