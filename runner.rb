#!/usr/bin/ruby

require_relative 'StoreProcessor'

def with_error_printing
  yield
rescue StandardError => error
  puts "#{__method__}: #{error.message}"
  puts "#{__method__} backtrace:"
  puts error.backtrace
  nil
end

with_error_printing do
  StoreProcessor.new('http://shopicruit.myshopify.com/')
                .get_filtered_total(%w(clocK wAtch))
end

with_error_printing do
  StoreProcessor.new('http://google.com')
                .get_filtered_total(%w(clocK wAtch))
end

# TODO: Split these into tests
# begin
#     processor = StoreProcessor.new("nonsense")
# rescue ArgumentError
#     p "Caught error!"
# end
#
# Types = [ "clock" ]
# processor.get_filtered_total(Types); puts
# processor.get_filtered_total([]); puts
# processor.get_filtered_total(['Elephants']); puts
# processor.get_filtered_total([ 'clock', 'watch' ]); puts
