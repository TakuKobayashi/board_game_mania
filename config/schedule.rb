# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "#{path}/log/cron.log"
set :rbenv_root, "/app/library/rbenv"

if defined? :rbenv_root
  job_type :rake,    %{cd :path && :environment_variable=:environment :rbenv_root/bin/rbenv exec bundle exec rake :task --silent :output}
  job_type :runner,  %{cd :path && :rbenv_root/bin/rbenv exec bundle exec rails runner -e :environment ':task' :output}
  job_type :script,  %{cd :path && :environment_variable=:environment :rbenv_root/bin/rbenv exec bundle exec script/:task :output}
end

every :day, at: '1:00' do
  rake "crawl:event"
end

every :day, at: '3:00' do
  rake "batch:bot_tweet"
end

every :day, at: '10:00' do
  rake "crawl:youtube"
end

every :day, at: '16:00' do
  rake "crawl:youtube_related_video"
end

every :day, at:'20:00' do
  rake '-s sitemap:refresh'
end