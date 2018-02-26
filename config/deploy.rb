# config valid only for current version of Capistrano
lock "3.8.2"

set :application, "board_game_mania"
set :repo_url, "https://github.com/TakuKobayashi/board_game_mania.git"
set :branch, fetch(:stage)
set :deploy_to, "/app/project/board_game_mania"
set :keep_releases, 3

set :linked_files, ["config/database.yml", ".env"]
set :linked_dirs, ["bin", "log", "tmp/pids", "tmp/sockets", "tmp/private", "public", "vendor/bundle"]

# Rails config
set :rails_env, fetch(:stage)
# auto migration
set :migration_role, :root
# check difference and skip if no change
set :conditionally_migrate, true

# Bundler config
set :bundle_path, -> { shared_path.join("bundle") }
set :bundle_binstubs, -> { shared_path.join("bin") }
set :bundle_without, (["development", "test", "production"] - [fetch(:stage).to_s]).join(" ")
set :bundle_flags, "--deployment --quiet --full-index"

# Whenever config
# auto update crontab
set :whenever_roles, :root
set :whenever_environment, fetch(:stage).to_s
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
