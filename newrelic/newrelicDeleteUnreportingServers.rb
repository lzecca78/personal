#!/bin/env ruby

require 'rubygems'
require 'net/http'
require 'uri'
require 'xmlsimple'

account_id = 'YOUR_NEWRELIC_ACCOUNT_ID'
header = { 'x-api-key' => 'YOUR_NEWRELIC_API_KEY' }

url = URI.parse("https://api.newrelic.com/api/v1/accounts/#{account_id}/server_settings.xml")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

resp = http.get(url.path, header)

xml_data = resp.body
data = XmlSimple.xml_in(xml_data)

data['server-setting'].each do |id|
  hostname = id['hostname']
  if hostname.to_s.match(/ws-(a|b|c)-[0-9]+/)  #put here a regexp to match the server on which you do autoscaling  that go down frequently and can be safely removed
    id['server-id'].each do |content|
      serverId = content['content']
      urlDelete = URI.parse("https://api.newrelic.com/api/v1/accounts/#{account_id}/servers/#{serverId}.xml")
      httpDelete = Net::HTTP.new(urlDelete.host, urlDelete.port)
      httpDelete.use_ssl = true
      reqDelete = Net::HTTP::Delete.new(urlDelete.request_uri, header)
      responseDelete = httpDelete.request(reqDelete)
      puts "deleted server with id #{serverId} hostname #{hostname} and delete http status code : #{responseDelete.code} "
    end
  else
    puts "#{hostname} doesn't match criteria"
  end
end
