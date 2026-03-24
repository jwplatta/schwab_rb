# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

gem_helper = Bundler::GemHelper.instance

def install_built_gem(gem_helper, local: false)
  gem_path = File.join(
    gem_helper.base,
    "pkg",
    "#{gem_helper.send(:name)}-#{gem_helper.send(:version)}.gem"
  )
  command = [*gem_helper.send(:gem_command), "install", gem_path, "--no-document"]
  command << "--local" if local
  sh(*command)
  Bundler.ui.confirm "#{gem_helper.send(:name)} (#{gem_helper.send(:version)}) installed."
end

Rake::Task["install"].clear
desc "Build and install the gem into system gems without generating documentation."
task "install" => "build" do
  install_built_gem(gem_helper)
end

Rake::Task["install:local"].clear
desc "Build and install the gem into system gems without network access or documentation."
task "install:local" => "build" do
  install_built_gem(gem_helper, local: true)
end

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]
