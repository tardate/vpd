require 'active_record'
require 'active_record/base'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter

      # get the current schema name.
      def current_schema
        query('SELECT current_schema', 'SCHEMA')[0][0]
      end

      # Returns true if table exists.
      # If the schema is not specified as part of +name+ then it will only find tables within
      # the current schema search path (regardless of permissions to access tables in other schemas)
      def table_exists?(name)
        schema, table = Utils.extract_schema_and_table(name.to_s)
        return false unless table

        binds = [[nil, table]]
        binds << [nil, schema] if schema

        exec_query(<<-SQL, 'SCHEMA', binds).rows.first[0].to_i > 0
          SELECT COUNT(*)
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE c.relkind in ('v','r')
          AND c.relname = $1
          AND n.nspname = #{schema ? '$2' : 'ANY (current_schemas(false))'}
        SQL
      end

      # Returns true if schema exists.
      def schema_exists?(name)
        exec_query(<<-SQL, 'SCHEMA', [[nil, name]]).rows.first[0].to_i > 0
          SELECT COUNT(*)
          FROM pg_namespace
          WHERE nspname = $1
        SQL
      end

      module Utils
        # Returns an array of <tt>[schema_name, table_name]</tt> extracted from +name+.
        # +schema_name+ is nil if not specified in +name+.
        # +schema_name+ and +table_name+ exclude surrounding quotes (regardless of whether provided in +name+)
        # +name+ supports the range of schema/table references understood by PostgreSQL, for example:
        #
        # * <tt>table_name</tt>
        # * <tt>"table.name"</tt>
        # * <tt>schema_name.table_name</tt>
        # * <tt>schema_name."table.name"</tt>
        # * <tt>"schema.name"."table name"</tt>
        def self.extract_schema_and_table(name)
          table, schema = name.scan(/[^".\s]+|"[^"]*"/)[0..1].collect{|m| m.gsub(/(^"|"$)/,'') }.reverse
          [schema, table]
        end
      end


    end
  end
end

