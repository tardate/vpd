module Vpd
  extend ActiveSupport::Concern

  module ClassMethods

    # Returns (and records) the initial schema_search_path.
    def initial_search_path
      @@initial_search_path ||= YAML::load(File.open('config/database.yml'))[Rails.env]["schema_search_path"]
      @@initial_search_path ||= '"$user",public'
    end

    # Creates +schema+ and optionally runs rails migrations to it.
    def create(schema,and_migrate = true)
      conn = ActiveRecord::Base.connection
      conn.execute("CREATE SCHEMA #{schema}") unless conn.schema_exists? schema
      self.migrate(schema) if and_migrate
    end

    # Runs rails migrations into +schema+
    # Preserves the current schema search path
    def migrate(schema, to_version = nil)
      conn = ActiveRecord::Base.connection
      return false unless conn.schema_exists? schema
      current_search_path = conn.schema_search_path
      conn.schema_search_path = schema
      ActiveRecord::Migrator.migrate('db/migrate', to_version)
      conn.schema_search_path = current_search_path
    end

    # Activates the nominated +schema+
    # * Prepends +schema+ to the schema search path
    # * If +verify_migration+ is true, will create the schema if required
    #   and ensure that it is migrated up-to-date
    def activate(schema,verify_migration = false)
      base_path = self.initial_search_path
      self.create(schema) if verify_migration
      conn = ActiveRecord::Base.connection
      return false unless conn.schema_exists?(schema)
      conn.schema_search_path = [schema, base_path].compact.join(',')
    end

    # Activates/returns session to default schema.
    def activate_default
      ActiveRecord::Base.connection.schema_search_path = self.initial_search_path
    end

  end

end
