require 'rubygems'
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
#  test.pattern = 'test/**/*_test.rb'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

#task :test => :check_dependencies

task :default => [:test, :rdoc]

gem 'rdoc'
require 'rdoc'
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Categorizer #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/*.rb')
  rdoc.main = "README.rdoc"
  rdoc.options += ["-SHN","-f","darkfish"]
end
