module Cloudscopes
  
  class Sample
    
    attr_reader :name, :value, :unit
    
    ec2_instanceid_file = "/var/lib/cloud/data/previous-instance-id"
    @@instanceid = File.exists?(ec2_instanceid_file) ? File.read(ec2_instanceid_file).chomp : nil
    
    def initialize(namespace, metric)
      @name = metric['name']
      @unit = metric['unit']
      @value = nil
      
      begin
        return if metric['requires'] and ! Monitoring.get_binding.eval(metric['requires']) 
        @value = Monitoring.get_binding.eval(metric['value'])
      rescue => e
        STDERR.puts("Error evaluating #{@name}: #{e}")
        puts e.backtrace
      end
    end
    
    def valid
      ! @value.nil?
    end
    
    def to_cloudwatch_metric_data
      return nil if @value.nil?
      data = { metric_name: @name, value: @value }
      data[:unit] = @unit if @unit
      data[:dimensions] = [ { name: "InstanceId", value: @@instanceid } ] unless @@instanceid.nil?
      data
    end
    
  end
  
end
