#!/usr/bin/env ruby
# frozen_string_literal: true

# Stream order book (Level 2) data for NYSE, NASDAQ, and Options
#
# Usage: ruby examples/stream_order_book.rb
#
# Requires SCHWAB_API_KEY, SCHWAB_APP_SECRET, and APP_CALLBACK_URL env vars.
# Token must already exist in the database (run login first).

require "schwab_rb"
require "dotenv/load"

Fields = SchwabRb::Stream::Fields

client = SchwabRb::Auth.init_client_easy(
  ENV.fetch("SCHWAB_API_KEY"),
  ENV.fetch("SCHWAB_APP_SECRET"),
  ENV.fetch("APP_CALLBACK_URL")
)

stream = SchwabRb::Stream::Client.new(client)

stream.on(:nyse_book, symbols: ["AAPL", "MSFT"], fields: Fields::Book::ALL) do |event|
  puts "=== NYSE BOOK ==="
  event["content"]&.each do |entry|
    puts "  Symbol: #{entry["key"]}"
    puts "  Bids: #{entry["2"]&.length || 0} levels"
    puts "  Asks: #{entry["3"]&.length || 0} levels"
  end
end

stream.on(:nasdaq_book, symbols: ["AMD", "NVDA"], fields: Fields::Book::ALL) do |event|
  puts "=== NASDAQ BOOK ==="
  event["content"]&.each do |entry|
    puts "  Symbol: #{entry["key"]}"
    puts "  Bids: #{entry["2"]&.length || 0} levels"
    puts "  Asks: #{entry["3"]&.length || 0} levels"
  end
end

stream.on(:options_book, symbols: ["AAPL  261218C00200000"], fields: Fields::Book::ALL) do |event|
  puts "=== OPTIONS BOOK ==="
  event["content"]&.each do |entry|
    puts "  Symbol: #{entry["key"]}"
  end
end

puts "Starting order book stream... Press Ctrl+C to stop."

trap("INT") do
  puts "\nStopping stream..."
  stream.stop
  exit
end

stream.start
