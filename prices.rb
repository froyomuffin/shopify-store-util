#!/usr/bin/ruby

require 'net/http'
require 'json'

uri = URI('http://shopicruit.myshopify.com/products.json')
page = 0
total = 0

loop { # TODO Maybe split the exploration from the collection. Maybe try streaming an implicit list.
    page += 1

    params = { :page => page }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    break if (products = JSON.parse(res.body)["products"]).empty?

    total +=
    products
        .select { |product| # Filter for clocks and watches
            product["product_type"].downcase.include? "clock" or
            product["product_type"].downcase.include? "watch"
        }
        .map { |product| # Collect prices of all variants TODO What if we only want the cheapest of the variants?
            product["variants"]
                .map { |variant|
                    variant["price"].to_f
                }
                .reduce(:+)
        }
        .inject(0) { |sum, variant_total| # Collect the total sum of each variant
            sum + variant_total.to_f 
        }
}

puts total
