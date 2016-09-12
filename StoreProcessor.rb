#!/usr/bin/ruby

require 'net/http'
require 'json'

# A processor used to get information from a Shopify shop.
class StoreProcessor
  # Create a URI from String and test it. Either operation could
  # throw an exception. If either fails, catch their exception
  # and focus them into a InitializationError
  def initialize(store_string)
    @product_uri = build_product_uri(store_string)
    fetch_products(@product_uri)
  rescue StandardError => error # Focus the exceptions
    raise InitializationError, error.message
  end

  # Gets the total cost to purchase all items of given types
  def get_filtered_total(item_types)
    puts "Getting total for item types #{item_types} from \"#{@product_uri}\""

    total = 0

    # We pick a large range of page numbers. This could be done better
    # if we were able to determine the number of pages before iterating
    (1..9_999_999).each do |page_number|
      # Make a copy as URI requires we modify the object to handle
      # different queries
      page_product_uri = @product_uri.dup

      # Build a URI for the page number
      page_product_uri.query = URI.encode_www_form(page: page_number)

      products = with_error_handling { fetch_products(page_product_uri) }

      break if products.nil?
      break if products.empty?

      filtered_products = filter_products(products, item_types)
      print_all_prices(filtered_products)

      filtered_variants_prices = all_variant_prices(filtered_products)

      total += filtered_variants_prices.reduce(0, :+)
    end

    # Some extra formatting to make sure we get exactly two decimals
    puts "TOTAL: $#{format('%.2f', total)}"

    total
  end

  private

  # Build a product URI from a string describing a Shopify store
  def build_product_uri(uri_string)
    product_uri = URI(uri_string)
    product_uri.path = '/products.json'

    product_uri
  end

  # Get a list of products
  def fetch_products(product_uri)
    puts "Fetching products from #{product_uri}"
    response = Net::HTTP.get_response(product_uri)
    response.value # Throws an exception if the response code is not 2xx

    JSON.parse(response.body)['products']
  end

  # Get a list of filtered products
  def filter_products(products, item_types)
    products.select do |product|
      item_types.any? do |type|
        product['product_type'].downcase.include? type.downcase
      end
    end
  end

  # Get a list of prices for each variant of every product from a product list
  def all_variant_prices(products)
    products.flat_map do |product|
      product['variants'].map do |variant|
        variant['price'].to_f
      end
    end
  end

  # Prints all variants of a product list with their prices
  def print_all_prices(products)
    products.each do |product|
      puts product['title']
      product['variants'].each do |variant|
        puts "  #{variant['title']} -> $#{variant['price']}"
      end
    end
  end

  # Run the content of a block and handle errors it may raise
  def with_error_handling
    yield
  rescue StandardError => error
    puts "#{__method__}: #{error.message}"
    puts "#{__method__} backtrace:"
    puts error.backtrace

    nil
  end
end

# An error used during initialization
class InitializationError < StandardError; end
