#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to fetch user preferences data and save as fixture
# Usage: ruby examples/fetch_user_preferences.rb

require_relative '../lib/schwab_rb'
require 'dotenv'
require 'json'
require 'fileutils'

Dotenv.load

def create_client
  token_path = ENV['TOKEN_PATH'] || 'schwab_token.json'
  SchwabRb::Auth.init_client_easy(
    ENV['SCHWAB_API_KEY'],
    ENV['SCHWAB_APP_SECRET'], 
    ENV['APP_CALLBACK_URL'],
    token_path
  )
end

def fetch_user_preferences
  client = create_client
  puts "Fetching user preferences..."
  
  response = client.get_user_preferences
  parsed_data = JSON.parse(response.body, symbolize_names: true)
  
  # Create fixtures directory if it doesn't exist
  fixtures_dir = File.join(__dir__, '..', 'spec', 'fixtures')
  FileUtils.mkdir_p(fixtures_dir)
  
  # Save the raw response
  fixture_file = File.join(fixtures_dir, 'user_preferences.json')
  File.write(fixture_file, JSON.pretty_generate(parsed_data))
  
  puts "User preferences data saved to: #{fixture_file}"
  puts "Sample data keys: #{parsed_data.keys.first(5)}"
  
rescue => e
  puts "Error fetching user preferences: #{e.message}"
  puts e.backtrace.first(3)
end

if __FILE__ == $0
  fetch_user_preferences
end
