#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to fetch price history data and save as fixture
# Usage: ruby examples/fetch_price_history.rb [SYMBOL]

require_relative "../lib/schwab_rb"
require "dotenv"
require "json"
require "fileutils"
require "pry"

Dotenv.load

def create_client
  token_path = ENV["TOKEN_PATH"] || "schwab_token.json"
  SchwabRb::Auth.init_client_easy(
    ENV.fetch("SCHWAB_API_KEY", nil),
    ENV.fetch("SCHWAB_APP_SECRET", nil),
    ENV.fetch("APP_CALLBACK_URL", nil),
    token_path
  )
end

def fetch_price_history(symbol = "$SPX",
  start_date = Date.new(Date.today.year, Date.today.month, 1),
  end_date = Date.today
)
  client = create_client
  puts "Fetching price history for #{symbol}..."

  puts "  - Fetching minute price history..."
  price_hist = client.get_price_history(
    symbol,
    period_type: SchwabRb::PriceHistory::PeriodTypes::DAY,
    period: SchwabRb::PriceHistory::Periods::ONE_DAY,
    frequency_type: SchwabRb::PriceHistory::FrequencyTypes::MINUTE,
    frequency: SchwabRb::PriceHistory::Frequencies::EVERY_MINUTE,
    start_datetime: start_date,
    end_datetime: end_date,
    need_extended_hours_data: true,
    need_previous_close: false,
    return_data_objects: true
  )

  puts "Price history data collection complete!"
  puts "Symbol: #{symbol}"
rescue StandardError => e
  puts "Error fetching price history: #{e.message}"
  puts e.backtrace.first(3)
end

if __FILE__ == $PROGRAM_NAME
  symbol = ARGV[0] || "$SPX"
  start_date = ARGV[1] ? Date.parse(ARGV[1]) : Date.new(2025, 8, 1)
  end_date = ARGV[2] ? Date.parse(ARGV[2]) : Date.today

  fetch_price_history(symbol, start_date, end_date)
end
