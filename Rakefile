require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :demo do
  %x{bin/demo > demo/demo.$(git rev-parse HEAD).html }
end
