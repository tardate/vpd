module Vpd

  # record the initial schema_search_path
  def self.initial_search_path
    @@initial_search_path ||= YAML::load(File.open('config/database.yml'))[Rails.env]["schema_search_path"]
    @@initial_search_path ||= '"$user",public'
  end

  # creates +schema+ and optionally runs rails migrations to it
  def self.create(schema,and_migrate = true)
    conn = ActiveRecord::Base.connection
    conn.execute("CREATE SCHEMA #{schema}") unless conn.schema_exists? schema
    self.migrate(schema) if and_migrate
  end

  # runs rails migrations into +schema+
  # preserves the current schema search path
  def self.migrate(schema, to_version = nil)
    conn = ActiveRecord::Base.connection
    return false unless conn.schema_exists? schema
    current_search_path = conn.schema_search_path
    conn.schema_search_path = schema
    ActiveRecord::Migrator.migrate('db/migrate', to_version)
    conn.schema_search_path = current_search_path
  end

  # prepends +schema+ to the schema search path
  # if verify_migration is true, will create the schema if required
  # and ensure that it is migrated up-to-date
  def self.activate(schema,verify_migration = false)
    base_path = self.initial_search_path
    self.create(schema) if verify_migration
    conn = ActiveRecord::Base.connection
    return false unless conn.schema_exists?(schema)
    conn.schema_search_path = [schema, base_path].compact.join(',')
  end

  def self.activate_default
    ActiveRecord::Base.connection.schema_search_path = self.initial_search_path
  end

end