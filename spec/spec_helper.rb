require "bundler/setup"
Bundler.setup

require "schwab_rb"
require "pry"
require "dotenv"
require_relative "./factories/accounts"

Dotenv.load

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.filter_run_when_matching :focus
end
