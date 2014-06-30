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
    
  end
  
end