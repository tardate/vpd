require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
$LOAD_PATH << './lib'
require 'vpd'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
    gem.name = %q{vpd}
    gem.version = Vpd::VERSION
    gem.homepage = %q{http://github.com/tardate/vpd}
    gem.license = "MIT"
    gem.summary = %Q{virtual private database for rails}
    gem.description = %Q{implements schema partitioning for multi-tenancy support in rails.
      Currently only supports PostgreSQL and is officially "experimental"!}
    gem.email = "paul@evendis.com"
    gem.authors = ["Paul Gallagher"]
    # Include your dependencies below. Runtime dependencies are required when using your gem,
    # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
    #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
    #  gem.add_development_dependency 'rspec', '> 1.2.3'
  end
  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "vpd #{Vpd::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
