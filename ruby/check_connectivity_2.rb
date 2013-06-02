#!/bin/env ruby

#handle missing libraries
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

# methods

def __port_is_open?(ip, port, seconds)
  begin
    Timeout::timeout(seconds) do
    begin
        s=TCPSocket.new(ip, port)
        s.close
        return true
        rescue Errno::ECONNREFUSED; Errno::EHOSTUNREACH
        return false
    end
  end
  rescue Timeout::Error
end
end

def IpFromName(domain)
  ip=Resolv.getaddress domain
  return ip
end

##script

my_file =File.open("connectivity.ini",{:row_sep => "\r\n"})
@Deduplicate={}
my_file.each_line do|line|
line.split('=')
@key=line.split[0]
@value=line.split[2]
  if line.match(/http/) and line.match(/^;/).nil?
    then
      # cut out the quotes from host"
      line_noquotes = @value.tr "\"|\'", ""
      URI("#{line_noquotes}").host.each_line do |domain|
      clear_domain=domain.sub!(/(\r?\n)*\z/, "")
     if @Deduplicate.select{|host, ip|domain.match(host)}
      then
       @Deduplicate[clear_domain]= "#{Resolv.getaddress(clear_domain)}""-""#{URI("#{line_noquotes}").port}"
      end
      end
end
end

@Deduplicate.each do |host, ip|
  portIp=ip.split('-')[1]
  hostIp=ip.split('-')[0]
  if __port_is_open?(hostIp, portIp, 3).nil?
    then
      puts "[ ERROR ] on port #{portIp} for #{host} on #{hostIp} #{__port_is_open?(hostIp, portIp, 3)}"
    else
      puts "[ OK ] check on port #{portIp} for #{host}"
  end
end
my_file.close
