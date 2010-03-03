require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "awesome_search"
    gem.summary = %Q{Organize complicated search results}
    gem.description = %Q{Organize complicated search results}
    gem.email = "peter.boling@peterboling.com"
    gem.homepage = "http://github.com/pboling/awesome_search"
    gem.authors = ["pboling"]
    gem.add_development_dependency "shoulda", ">= 0"
    gem.add_runtime_dependency "activesupport", ">= 2.1"
    gem.files = [
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "awesome_search.gemspec",
     "init.rb",
     "lib/awesome_search.rb",
     "lib/awesome/search.rb",
     "lib/awesome/super_search.rb",
     "lib/awesome/triage.rb",
     "lib/awesome/definitions/bits.rb",
     "lib/awesome/definitions/filters.rb",
     "lib/awesome/definitions/locales.rb",
     "lib/awesome/definitions/types.rb",
     "rails/init.rb",
     "test/helper.rb",
     "test/test_awesome_search.rb",
     "test/test_multiple.rb",
     "test/search_classes/search_amazon.rb",
     "test/search_classes/search_ebay.rb",
     "test/search_classes/search_google.rb",
     "test/search_classes/search_local.rb"
  ]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "awesome_search #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
