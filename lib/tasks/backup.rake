namespace :backup do
  task export_active_records_data: :environment do
    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    host = Regexp.escape(configuration['host'].to_s)
    database = Regexp.escape(configuration['database'].to_s)
    username = Regexp.escape(configuration['username'].to_s)
    password = Regexp.escape(configuration['password'].to_s)
    unless Dir.exists?(Rails.root.join("db", "seeds"))
      FileUtils.mkdir(Rails.root.join("db", "seeds"))
    end
    Rails.application.eager_load!
    model_classes = ActiveRecord::Base.descendants.select{|m| m.table_name.present? }.uniq{|m| m.table_name }
    model_classes.each do |model_class|
      export_table_directory_name = Rails.root.join("db", "seeds", model_class.table_name)
      export_full_dump_sql = Rails.root.join("db", "seeds", model_class.table_name + ".sql")
      mysqldump_commands = ["mysqldump", "-u", username, "-h", host]
      if password.present?
        mysqldump_commands << "-p#{password}"
      end
      mysqldump_commands += [database, model_class.table_name, "--no-create-info","-c","--order-by-primary", "--skip-extended-insert", "--skip-add-locks", "--skip-comments", "--compact", ">", export_full_dump_sql]
      system(mysqldump_commands.join(" "))
      if Dir.exists?(export_table_directory_name)
        FileUtils.remove_dir(export_table_directory_name)
      end
      Dir.mkdir(export_table_directory_name)
      system("split -l 10000 -d --additional-suffix=.sql #{export_full_dump_sql} #{export_table_directory_name}/")
      FileUtils.rm(export_full_dump_sql)
    end
  end
end