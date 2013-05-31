# wheneverize .
#whenever --update-crontab store
  job_type :rake, "cd :path && PATH=/usr/bin:$PATH RAILS_ENV=:environment bundle exec rake :task :output"
set :environment, 'development'
  set :output, "/var/log/missionfig/whenever.log"
#
every 1.hours do
  rake "report:portfolio_hourly"
end
every 1.minute do
   runner "UserApplication.cron_demo"
end

#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
