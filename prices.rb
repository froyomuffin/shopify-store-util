#!/usr/bin/ruby

require 'net/http'
require 'json'

uri = URI('http://shopicruit.myshopify.com/products.json')
page = 0
total = 0
Filters = [ "clock", "watch" ] # TODO What if we want to change this

loop do # TODO Maybe split the exploration from the collection. Maybe try streaming an implicit list.
    page += 1

    params = { :page => page }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    break if (products = JSON.parse(res.body)["products"]).empty?

    total +=
    products
    .select do |product| # Filters for clocks and watches
        Filters.any? { |filter| product["product_type"].downcase.include? filter }
    end
    .each do |product|
        p product["title"]
    end
    .flat_map do |product| # Extract prices of each variant and expand the enumerable(?) <-- TODO Not sure of terminology TODO What if we want to grab the cheapest variant?
        product["variants"].map { |variant| variant["price"].to_f }
    end
    .reduce(:+) # Sum the prices from all the item variants filtered
end

puts total
