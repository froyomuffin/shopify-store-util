#!/usr/bin/ruby

require 'optparse'
require 'ostruct'
require_relative 'StoreProcessor'

# TODO: Formatting, safety, cleanup
options = OpenStruct.new
options.types = Array.new

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"
  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-s", "--store STORE", "Store URI") do |store_uri|
    options.store_uri = store_uri
  end

  opts.on("--types x y z", Array, "Item types") do |types|
    options.types.push(*types)
  end

  opts.on("-f", "--type TYPE", "Item types") do |type|
    options.types.push(type)
  end

  opts.on_tail("-h", "--help", "Help") do
    puts opts.banner
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

  puts"Couldn't get the total! :("
end

carefully do 
  StoreProcessor.new(options.store_uri)
                .get_filtered_total(options.types)
end
