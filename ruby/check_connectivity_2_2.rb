#!/usr/bin/env ruby

#handle missing libraries
begin
      require 'rubygems'
rescue LoadError
      system("gem install rubygems")
end


begin
      require 'socket'
rescue LoadError
      system("gem install socket")
end
begin
      require 'uri'
rescue LoadError
      system("gem install uri")
end

begin
      require 'timeout'
rescue LoadError
      system("gem install timeout")
end

begin
      require 'resolv'
rescue LoadError
      system("gem install resolv")
end

require 'pp'
require 'net/http'
require 'net/https'
# global variables
@timeoutSeconds=3

# methods

def portIsOpen?(ip, port, domain)
    begin
    Timeout::timeout(@timeoutSeconds) do
        begin
            s=TCPSocket.new(ip, port)
            s.close
            return true
        rescue
            puts  "*******UNREACHABLE ******""[ERROR] caused by ""#{Errno::ECONNREFUSED; Errno::EHOSTUNREACH}"" from #{ip} that lookup to #{domain}"
            return true
         end
        end
    rescue Timeout::Error
    end
end

def responseNotDesidered(url)
    uri = URI(url)
puts uri
    begin
        Timeout::timeout(@timeoutSeconds) do
        begin
            response = Net::HTTP.get_response(uri)
            puts response.nil?
        rescue
            puts "ERROR while retriving response from #{url}"
            return false
        end
        if response.code.match(/^4/) or response.code.match(/^5/)
        then
            puts "ERROR the response is #{response.code} from #{url}"
            return false
        end
        end
        return true
    rescue 
            puts "ERROR timeout raised while retriving response from #{url}"
            return false
    end
end

def IpFromName(domain)
  begin
  ip=Resolv.getaddress domain
  rescue
    puts "[ERROR] while trying to obtain ipaddress from #{domain}"
  end
  return ip
end

# catch argument
fd=nil

if ARGV.length == 0
then
    puts "Usage:  ruby check_connectivity_<version>_<version>.rb <path_ini_file>"
    exit 2
end

ARGV.each do |myFile|
    puts "Using #{myFile}"
    begin   
        fd = File.open(myFile)
    rescue 
        puts "Usage:  ruby check_connectivity_<version>_<version>.rb <path_ini_file>"
        exit 2
    end    
end




##script
@Deduplicate={}
fd.each_line do|line|
    line.split('=')
    key=line.split[0]
    value=line.split[2]
    if  line.match(/http/) and line.match(/^;/).nil?
        then
        # cut out the quotes from host"
        line_noquotes = value.tr "\"|\'", ""
        URI("#{line_noquotes}").host.each_line do |domain|
            clear_domain=domain.sub!(/(\r?\n)*\z/, "")
            @Deduplicate[line_noquotes]= "#{IpFromName(clear_domain)}""-""#{URI("#{line_noquotes}").port}"
      end
    end
end

@Deduplicate.each do |host, ip|
    portIp=ip.split('-')[1]
    hostIp=ip.split('-')[0]
    if portIsOpen?(hostIp, portIp, host).nil?
    then
        puts "[ ERROR:PORT:#{portIp} ] on port #{portIp} and ip #{hostIp} from #{host}"
    else
        if responseNotDesidered(host)
        then
            puts "[ OK ] check on port #{portIp} for #{host}"
        end
    end
end
fd.close
