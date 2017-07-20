#!/bin/sh

git pull
RAILS_ENV=production rails assets:precompile
kill -9 `cat tmp/pids/server.pid`
SECRET_KEY_BASE=$(rake secret) rails server -e production -p 3010 -d