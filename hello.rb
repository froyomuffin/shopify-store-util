#!/usr/bin/ruby

require 'net/http'
require 'json'

uri = URI('http://shopicruit.myshopify.com/products.json')
page = 0
fullhash = Hash.new

loop do
    page += 1

    params = { :page => page }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    break if (hash = JSON.parse(res.body))["products"].empty?

    p "Merging page #{page}"
    p fullhash.length
    fullhash = fullhash.merge(hash)
    p fullhash["products"].length
end

#puts JSON.pretty_generate(fullhash)
