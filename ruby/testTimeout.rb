#!/usr/bin/env ruby

require 'uri'
require 'net/http'

begin
statuts = Timeout::timeout(1) {
uri=URI('http://www.google.com:8080')

response = Net::HTTP.get_response(uri)
puts response
}
rescue Timeout::Error
    puts "Timeout!"
end

