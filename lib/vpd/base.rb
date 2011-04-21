module Vpd
  def self.add_schema_to_path(schema)
    conn = ActiveRecord::Base.connection
    schemas = [schema,conn.schema_search_path]
    conn.schema_search_path = schemas.compact.join(',')
  end

  def self.create(schema)
    conn = ActiveRecord::Base.connection
    conn.execute("CREATE SCHEMA #{schema}") unless conn.schema_exists? schema
    self.migrate(schema)
  end

  def self.migrate(schema, to_version = nil)
    conn = ActiveRecord::Base.connection
    return false unless conn.schema_exists? schema
    save_current_search_path = conn.schema_search_path
    conn.schema_search_path = schema
    ActiveRecord::Migrator.migrate('db/migrate', to_version)
    conn.schema_search_path = save_current_search_path
  end

  def self.activate(schema,verify_migration = false)
    conn = ActiveRecord::Base.connection
    return false unless conn.schema_exists? schema
    self.migrate(schema) if verify_migration
    conn.schema_search_path = [schema, 'public'].compact.join(',')
  end
end