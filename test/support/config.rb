require 'yaml'
require 'erubis'
require 'fileutils'
require 'pathname'

module VPDTest
  class << self
    def config
      @config ||= read_config
    end

    private

    def config_file
      Pathname.new(ENV['VPDCONFIG'] || TEST_ROOT + '/config.yml')
    end

    def read_config
      unless config_file.exist?
        FileUtils.cp TEST_ROOT + '/config.example.yml', config_file
      end

      erb = Erubis::Eruby.new(config_file.read)
      expand_config(YAML.parse(erb.result(binding)).transform)
    end

    def expand_config(config)
      config['connections'].each do |adapter, connection|
        dbs = [['vpdunit', 'vpd_unittest']]
        dbs.each do |name, dbname|
          unless connection[name].is_a?(Hash)
            connection[name] = { 'database' => connection[name] }
          end

          connection[name]['database'] ||= dbname
          connection[name]['adapter']  ||= adapter
        end
      end

      config
    end
  end
end
