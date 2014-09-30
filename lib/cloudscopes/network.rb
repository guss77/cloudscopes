require 'socket'
require 'timeout'

module Cloudscopes
  
  class Network
    
    def local_ip
      Socket.ip_address_list.detect {|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? }.ip_address
    end
    
    def port_open?(port)
      begin
        Timeout::timeout(1) do
          begin
            TCPSocket.new(local_ip, port).close
            return true
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            return false
          end
        end
      rescue Timeout::Error
        return false
      end
    end
    
    def proc_ip_hex_to_dotted(hexstr)
      hexstr.scan(/../).map(&:hex).reverse*"."
    end
    
    def sockets
      File.read("/proc/net/tcp").split("\n").drop(1).collect do |l| 
        l.strip.split(/\s+/) 
      end.collect do |s|
        s[1..2] = s[1].split(/:/) + s[2].split(/:/) # split local/remote addresses to ip and port as separate fields
        s[1] = proc_ip_hex_to_dotted(s[1])
        s[2] = s[2].to_i(16)
        s[3] = proc_ip_hex_to_dotted(s[3])
        s[4] = s[4].to_i(16)
        s.drop(1) # drop the index
      end
    end
    
    def open_server_ports(port)
      sockets.select do |s|
        s[4].to_i == 1 # only established sockets
      end.select do |s| 
        s[1] == port
      end
    end
    
  end
  
end
