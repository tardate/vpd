require 'active_record'
require 'active_record/base'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter

      # get the current schema
      def current_schema
        query('SELECT current_schema', 'SCHEMA')[0][0]
      end

      # tests it +name+ schema exists
      def schema_exists?(name)
        query(<<-SQL).first[0].to_i > 0
            SELECT COUNT(*)
            FROM pg_namespace
            WHERE nspname = '#{name.gsub(/(^"|"$)/,'')}'
        SQL
      end

      # Overrides ActiveRecord::ConnectionAdapters::PostgreSQLAdapter#table_exists?
      # Change to only look in the current schema - unless schema is specified in the name
      def table_exists?(name)
        schema, table = extract_schema_and_table(name.to_s)
        schema ||= current_schema

        binds = [[nil, table.gsub(/(^"|"$)/,'')]]
        binds << [nil, schema] if schema

        query(<<-SQL, 'SCHEMA').first[0].to_i > 0
            SELECT COUNT(*)
            FROM pg_tables
            WHERE tablename = '#{table.gsub(/(^"|"$)/,'')}'
            #{schema ? "AND schemaname = '#{schema}'" : ''}
        SQL
      end

      # Extracts the table and schema name from +name+
      # - copied from HEAD but not in 3.0.7 yet
      def extract_schema_and_table(name)
        schema, table = name.split('.', 2)

        unless table # A table was provided without a schema
          table  = schema
          schema = nil
        end

        if name =~ /^"/ # Handle quoted table names
          table  = name
          schema = nil
        end
        [schema, table]
      end

    end
  end
end

