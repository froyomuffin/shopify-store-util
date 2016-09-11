#!/usr/bin/ruby

require 'net/http'
require 'json'

class InitializationError < StandardError; end

class StoreProcessor

  # Create a URI from String and test it. Either operation could throw an exception.
  # If either fails, catch their exception and focus them into a InitializationError
  def initialize(store_string)
    @product_uri = build_product_uri(store_string)
    fetch_products(@product_uri)
  rescue StandardError => error # Focus the exceptions
    raise InitializationError, error.message
  end

  # Gets the total cost for all items that match a provided item type filter
  def get_filtered_total(item_types)
    local_product_uri = @product_uri.dup # Make a copy as URI requires we modify the object to handle different queries

    puts "Getting total for item types #{item_types} from \"#{local_product_uri}\""

    page = 0
    total = 0

    # TODO: This part could be done more elegantly if we knew ahead of time the number of pages.
    # We could build map and filter directly from the pages and avoid this loop
    # IF we do do something like that, make sure to create local_product_uri for
    # each page, otherwise, we may get issue when running a parallel stream
    loop do
      page += 1
      params = { page: page }
      local_product_uri.query = URI.encode_www_form(params)

      products = with_error_handling { fetch_products(local_product_uri) } # This is a little 

      break if products.nil? || products.empty?

      total +=
      products
      .select do |product| # Filter for clocks and watches
        item_types.any? { |type| product['product_type'].downcase.include? type.downcase }
      end
      .flat_map do |product| # Extract prices of each variant
        puts product['title']
        product['variants'].map do |variant|
          puts "  #{variant['title']} -> $#{variant['price']}"
          variant['price'].to_f
        end
      end
      .reduce(0) { |a, e| a + e } # Sum the prices from all the item variants filtered
    end

    puts "TOTAL: $#{format('%.2f', total)}" # Some extra formatting to make sure we get exactly two decimals
    total
  end

  private

  def with_error_handling
    yield
  rescue StandardError => error
    puts "#{__method__}: #{error.message}"
    nil
  end

  def fetch_products(product_uri)
    puts "Fetching products from #{product_uri}"
    response = Net::HTTP.get_response(product_uri)
    response.value # Throws an exception if the response code is not 2xx

    products = JSON.parse(response.body)['products']

    products
  end

  def build_product_uri(uri_string)
    product_uri = URI(uri_string)
    product_uri.path = '/products.json'

    product_uri
  end

end

# TODO: Move out everything under this line

def with_error_printing
  yield
rescue StandardError => error
  puts "#{__method__}: #{error.message}"
  nil
end

with_error_printing { StoreProcessor.new('http://shopicruit.myshopify.com/').get_filtered_total(%w(clocK wAtch)) }
with_error_printing { StoreProcessor.new('http://google.com').get_filtered_total(%w(clocK wAtch))  }

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
