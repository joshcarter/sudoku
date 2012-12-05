require 'rubygems'
require 'rake/testtask'

desc "Default Task"
task :default => [:test]

Rake::TestTask.new :test do |test|
  test.verbose = false
  test.warning = true
  test.test_files = ['test.rb']
end

