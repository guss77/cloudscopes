require 'net/http'

module Cloudscopes

  class Ec2

    @@baseurl = 'http://169.254.169.254/latest/meta-data'

    HYPERVISOR_UUID_PATH = '/sys/hypervisor/uuid'.freeze
    DMI_PRODUCT_UUID_PATH = '/sys/devices/virtual/dmi/id/product_uuid'.freeze

    # see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/identify_ec2_instances.html for
    # details
    def self.runs_on_ec2?
      path =
          if File.exists?(HYPERVISOR_UUID_PATH)
            HYPERVISOR_UUID_PATH
          elsif File.exists?(DMI_PRODUCT_UUID_PATH)
            DMI_PRODUCT_UUID_PATH
          end
      !!path && File.read(path).downcase.start_with?('ec2')
    end

    def instance_id
      @@instanceid ||= Net::HTTP.get(URI("#{@@baseurl}/instance-id"))
    end

    def availability_zone
      @@az ||= Net::HTTP.get(URI("#{@@baseurl}/placement/availability-zone"))
    end

  end

end
