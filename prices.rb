#!/usr/bin/ruby

require 'net/http'
require 'json'

class StoreProcessor
  def initialize(store_uri)
    if store_uri.class != URI::HTTP
      raise ArgumentError, 'Failed to construct StoreProcessor: No URI::HTTP object specified!'
    end

    @product_uri = store_uri
    @product_uri.path = '/products.json'
  end

  def get_filtered_total(item_types)
    puts "Getting total for item types #{item_types} from #{@product_uri.host}"

    page = 0
    total = 0

    loop do # This part could be done more elegantly if we knew ahead of time the number of pages. We could build map and filter directly from the pages and avoid this loop
      page += 1
      params = { page: page }
      @product_uri.query = URI.encode_www_form(params)

      products = fetch_products

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

  def fetch_products
    response = Net::HTTP.get_response(@product_uri)
    response.value # Throws an exception if the response code is not 2xx

    products = JSON.parse(response.body)['products']
  rescue StandardError => error
    puts "Could not get products: #{error.message}"
  ensure
    products
  end
end

uri = URI('http://shopicruit.myshopify.com/')

processor = StoreProcessor.new(uri)
processor2 = StoreProcessor.new(URI('http://google.com'))

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

processor.get_filtered_total(%w(clocK wAtch))
puts
processor2.get_filtered_total(%w(clocK wAtch))
puts
