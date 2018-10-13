#!/bin/sh

git pull
bundle install
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec rails assets:clean
RAILS_ENV=production bundle exec rails assets:precompile --trace
bundle exec whenever --update-crontab
bundle exec spring stop
kill -9 `cat tmp/pids/server.pid`
SECRET_KEY_BASE=$(rake secret) RAILS_SERVE_STATIC_FILES=true bundle exec rails server -e production -p 3010 -d