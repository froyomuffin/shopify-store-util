#!/usr/bin/ruby

# Quick script to run our StoreProcessor in a CLI util!

require 'optparse'
require 'ostruct'
require_relative 'StoreProcessor'

# Help if run without options
ARGV << '-h' if ARGV.empty?

options = OpenStruct.new
options.types = Array.new

OptionParser.new do |opts|
  opts.banner =
    "This is a small util used to get info on Shopify stores. \n" +
    "With this, you can: \n" +
    "  1. Get a list of the various types of items of a store. \n" +
    "     e.g. #{File.basename(__FILE__)} --store 'http://shopicruit.myshopify.com' \n" +
    "  2. Search a store for all items of given types! \n" +
    "     e.g. #{File.basename(__FILE__)} --store 'http://shopicruit.myshopify.com' --types 'watch,clock'"

  opts.separator ""
  opts.separator "Usage: #{File.basename(__FILE__)} [options]"
  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-s", "--store STORE_URI", String, "URI to a Shopify store. Be sure to include the protocol!") do |store_uri|
    options.store_uri = store_uri
  end

  opts.on("-t", "--types x,y,z", Array, "Comma separated list of item types.") do |types|
    options.types.push(*types)
  end

  opts.on("-f", "--type TYPE", String, "An item type. This option can be used many times.") do |type|
    options.types.push(type)
  end

  opts.on_tail("-h", "--help", "This message.") do
    puts opts
    exit
  end
end.parse!

def carefully
  yield
rescue StandardError => error
  puts

  puts "Error message: #{error.message}"
  puts "Error backtrace:"
  puts error.backtrace

  puts

  puts"Couldn't complete task! :("
end

if options.store_uri.nil?
  puts "Error! You need to provide a store URI! Use -h for help!"
  exit
end

carefully do
  processor = StoreProcessor.new(options.store_uri)
  if options.types.empty?
    processor.print_types
  else
    processor.get_filtered_total(options.types)
  end
end
