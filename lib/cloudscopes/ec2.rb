require 'net/http'

module Cloudscopes
  
  class Ec2
    
    @@baseurl = 'http://169.254.169.254/latest/meta-data'
    
    def instance_id
      @@instanceid ||= Net::HTTP.get(URI("#{@@baseurl}/instance-id"))
    end
    
    def availability_zone
      @@az ||= Net::HTTP.get(URI("#{@@baseurl}/placement/availability-zone"))
    end
    
  end
  
end
