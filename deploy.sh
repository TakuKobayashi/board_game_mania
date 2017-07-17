#!/bin/sh

git pull
RAILS_ENV=production rails db:migrate
RAILS_ENV=production bundle exec rake assets:precompile
whenever --update-crontab
kill -9 `cat tmp/pids/server.pid`
SECRET_KEY_BASE=$(rake secret) rails server -e production -p 3010 -d