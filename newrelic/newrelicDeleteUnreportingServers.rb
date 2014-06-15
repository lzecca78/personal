#!/bin/env ruby

require 'rubygems'
require 'net/http'
require 'uri'
require 'xmlsimple'
require 'json'


account_id = 'YOUR_NEWRELIC_ACCOUNT_ID'
header = { 'x-api-key' => 'YOUR_NEWRELIC_API_KEY' }

url = URI.parse("https://api.newrelic.com/api/v1/accounts/#{account_id}/server_settings.xml")

urlJson = URI.parse("https://api.newrelic.com/v2/servers.json")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

httpJson = Net::HTTP.new(urlJson.host, urlJson.port)
httpJson.use_ssl = true

resp = http.get(url.path, header)
respJson = httpJson.get(urlJson.path, header)

xml_data = resp.body
data = XmlSimple.xml_in(xml_data)

@json_data = JSON.parse(respJson.body)['servers']

def ReportingStatus(myid)
  mymap =@json_data.map{|k|
    {
      "jsonid" => (k["id"]),
      "myreporting" => (k["reporting"])
    }
  }
  mymap.each do |line|
    if line['jsonid'].to_i == myid.to_i
      return line['myreporting']
    end
  end
end

data['server-setting'].each do |id|
  hostname = id['hostname']
  id['server-id'].each do |content|
    serverId = content['content']
    reporting = ReportingStatus(serverId)
    if hostname.to_s.match(/ws-(a|b|c)-[0-9]+/) and reporting != true  #put here a regexp to match the server on which you do autoscaling  that go down frequently and can be safely removed
      urlDelete = URI.parse("https://api.newrelic.com/api/v1/accounts/#{account_id}/servers/#{serverId}.xml")
      httpDelete = Net::HTTP.new(urlDelete.host, urlDelete.port)
      httpDelete.use_ssl = true
      reqDelete = Net::HTTP::Delete.new(urlDelete.request_uri, header)
      responseDelete = httpDelete.request(reqDelete)
      puts "deleted server with id #{serverId} hostname #{hostname} and delete http status code : #{responseDelete.code} "
    else
      puts "#{hostname} doesn't match criteria or reporting status is still active on the server #{hostname}"
    end
  end
end
