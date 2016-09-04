#!/usr/bin/ruby

require 'net/http'
require 'json'

uri = URI('http://shopicruit.myshopify.com/products.json')
page = 0
total = 0
Filters = [ "clock", "watch" ] # TODO What if we want to change this

loop do # This part could be done more elegantly if we knew ahead of time the number of pages. We could build map and filter directly from the pages and avoid this loop. As a bonus, the lot can be run through parallel :(
    page += 1

    params = { :page => page }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    break if (products = JSON.parse(res.body)["products"]).empty?

    total +=
    products
    .select do |product| # Filter for clocks and watches
        Filters.any? { |filter| product["product_type"].downcase.include? filter }
    end
    .each do |product|
        p product["title"]
    end
    .flat_map do |product| # Extract prices of each variant 
        product["variants"].map { |variant| variant["price"].to_f }
    end
    .each do |price|
        p price
    end
    .reduce(:+) # Sum the prices from all the item variants filtered
end

puts total
