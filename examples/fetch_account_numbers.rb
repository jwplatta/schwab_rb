#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to fetch account numbers data and save as fixture
# Usage: ruby examples/fetch_account_numbers.rb

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

def fetch_account_numbers
  client = create_client
  puts "Fetching account numbers..."
  
  response = client.get_account_numbers
  parsed_data = JSON.parse(response.body, symbolize_names: true)
  
  # Create fixtures directory if it doesn't exist
  fixtures_dir = File.join(__dir__, '..', 'spec', 'fixtures')
  FileUtils.mkdir_p(fixtures_dir)
  
  # Save the raw response
  fixture_file = File.join(fixtures_dir, 'account_numbers.json')
  File.write(fixture_file, JSON.pretty_generate(parsed_data))
  
  puts "Account numbers data saved to: #{fixture_file}"
  puts "Sample data: #{parsed_data.first(2)}"
  
rescue => e
  puts "Error fetching account numbers: #{e.message}"
  puts e.backtrace.first(3)
end

if __FILE__ == $0
  fetch_account_numbers
end
