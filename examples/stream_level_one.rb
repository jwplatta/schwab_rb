#!/usr/bin/env ruby
# frozen_string_literal: true

# Stream Level 1 equity quotes
#
# Usage: ruby examples/stream_level_one.rb
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

stream.on(:level_one_equities,
  symbols: ["AAPL", "MSFT", "GOOGL", "AMZN"],
  fields: [
    Fields::LevelOneEquity::SYMBOL,
    Fields::LevelOneEquity::BID_PRICE,
    Fields::LevelOneEquity::ASK_PRICE,
    Fields::LevelOneEquity::LAST_PRICE,
    Fields::LevelOneEquity::TOTAL_VOLUME,
    Fields::LevelOneEquity::NET_CHANGE,
    Fields::LevelOneEquity::NET_CHANGE_PERCENT
  ]
) do |event|
  event["content"]&.each do |entry|
    symbol = entry["key"]
    bid = entry["1"]
    ask = entry["2"]
    last = entry["3"]
    volume = entry["8"]
    change = entry["18"]
    change_pct = entry["42"]

    parts = ["#{symbol}:"]
    parts << "Last=#{last}" if last
    parts << "Bid=#{bid}" if bid
    parts << "Ask=#{ask}" if ask
    parts << "Vol=#{volume}" if volume
    parts << "Chg=#{change}" if change
    parts << "Chg%=#{change_pct}" if change_pct

    puts parts.join(" ")
  end
end

puts "Starting Level 1 equity stream... Press Ctrl+C to stop."

trap("INT") do
  puts "\nStopping stream..."
  stream.stop
  exit
end

stream.start
