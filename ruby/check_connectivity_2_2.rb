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

require 'csv'
require 'pp'
require 'net/http'
require 'net/https'
# global variables
@timeoutSeconds=3
@fileParsed=''
@NOT_NECESSARY=''
# methods

def csvAddRow(status=@NOT_NECESSARY, typeOfStatus=@NOT_NECESSARY, ip=@NOT_NECESSARY, fqdn=@NOT_NECESSARY, responseHttp=@NOT_NECESSARY)
CSV::Writer.generate(@csvFile).add_row([status,typeOfStatus,ip,fqdn,responseHttp])
end

def portIsOpen?(ip, port, domain)
  if ip.nil?
    then
    return false
  end
    begin
    status = Timeout::timeout(@timeoutSeconds) {
        begin
            s=TCPSocket.new(ip, port)
            s.close
            return true
        rescue
            puts  "    ERROR::socket_unreachable : caused by ""#{Errno::ECONNREFUSED; Errno::EHOSTUNREACH}"" from #{ip} that lookup to #{domain}"
            csvAddRow('ERROR','socket_unreachable',ip,domain, @NOT_NECESSARY)
            return false
         end
    }
    rescue Timeout::Error
        return false
    end
end

def responseNotDesidered(url)
    uri = URI(url)
    response = ''
    begin
        status = Timeout::timeout(@timeoutSeconds) {
        begin
            response = Net::HTTP.get_response(uri)
        rescue
            puts "	ERROR::http_no_response : while retriving response from #{url}"
            csvAddRow('ERROR','http_no_response',@NOT_NECESSARY,url, @NOT_NECESSARY)
            return false
        end
        if response.code.match(/^4/) or response.code.match(/^5/)
        then
            puts "	ERROR::http_error_code the response is #{response.code} from #{url}"
            csvAddRow('ERROR','http_error_code',@NOT_NECESSARY,url, response.code)
            return false
        end
        puts "OK : check on port #{URI(url).port} for #{URI(url).host}"
        csvAddRow('OK',@NOT_NECESSARY,@NOT_NECESSARY,URI(url), response.code)
        return true
        }
    rescue Timeout::Error
            puts "	ERROR::network_timeout : timeout raised while retriving response from #{url}"
            csvAddRow('ERROR','network_timeout',@NOT_NECESSARY,url,@NOT_NECESSARY)
            return false
    end
end

def IpFromName(domain)
  begin
  ip=Resolv.getaddress domain
  rescue
    puts "    ERROR::error_resolve : while trying to obtain ipaddress from #{domain}"
            csvAddRow('ERROR','error_resolve',@NOT_NECESSARY,domain, @NOT_NECESSARY)
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
      @fileParsed=myFile
        fd = File.open(myFile)
    rescue
        puts "Usage:  ruby check_connectivity_<version>_<version>.rb <path_ini_file>"
        exit 2
    end
end


timeToString = Time.new.strftime('%Y%m%d%H%M%S')

@csvFile = File.open(File.basename(@fileParsed) + timeToString +'.csv', 'w')
puts @csvFile.path


#create index of csv
CSV::Writer.generate(@csvFile).add_row(['STATUS','TYPE','IP', 'FQDNq','HTTP STATUS'])
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
        puts "    ERROR::socket_port : PORT:#{portIp} ] on port #{portIp} and ip #{hostIp} from #{host}"
            csvAddRow('ERROR','socket_port',hostIp,host,@NOT_NECESSARY)
    else
         responseNotDesidered(host)
    end
end
fd.close
@csvFile.close
