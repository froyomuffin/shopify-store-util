#!/usr/bin/ruby

require 'net/http'
require 'json'

class StoreProcessor
    def initialize(storeUri)
        # TODO Type checking?
        @ProductsUri = storeUri
        @ProductsUri.path = "/products.json"
    end

    def getFilteredTotal(itemTypes) 
        page = 0
        total = 0

        puts "Getting total for item types #{itemTypes}"

        loop do # This part could be done more elegantly if we knew ahead of time the number of pages. We could build map and filter directly from the pages and avoid this loop 
            page += 1
            params = { :page => page }

            @ProductsUri.query = URI.encode_www_form(params)
            res = Net::HTTP.get_response(@ProductsUri)

            break if (products = JSON.parse(res.body)["products"]).empty?

            total +=
            products
                .select do |product| # Filter for clocks and watches
                    itemTypes.any? { |filter| product["product_type"].downcase.include? filter }
                end
                .flat_map do |product| # Extract prices of each variant 
                    puts product["title"]
                    product["variants"].map do |variant| 
                        puts "\t #{variant["title"]} -> #{variant["price"]}"
                        variant["price"].to_f
                    end
                end
                .inject(0) { |sum, price| sum + price } # Sum the prices from all the item variants filtered
        end

        total = total.round(2)

        puts "TOTAL: #{'%.2f' % total}" # Some extra formatting to make sure we get exactly two decimals
        return total
    end
end

uri = URI('http://shopicruit.myshopify.com/')
Types = [ "clock" ]

processor = StoreProcessor.new(uri)
processor.getFilteredTotal(Types);
processor.getFilteredTotal([]);
processor.getFilteredTotal(["Elephants"]);
processor.getFilteredTotal([ "clock", "watch" ]);
