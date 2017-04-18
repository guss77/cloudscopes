##
# public API expressed through kernel (global) methods, for simplicity
#

def publish(samples)
  unless system("test -f /sys/hypervisor/uuid && test `head -c 3 /sys/hypervisor/uuid` = ec2")
    raise "Not running in EC2, so won't publish!"
  end
  samples.each do |type,metric_samples|
    begin
      valid_data = metric_samples.select(&:valid)
      next if valid_data.empty?
      # slice metrics to chunks
      # put_metric_data is limited to 40KB per POST request
      valid_data.each_slice(4) do |slice|
        Cloudscopes.client.put_metric_data namespace: type,
                                          metric_data: slice.collect(&:to_cloudwatch_metric_data)
      end
    rescue Exception => e
      puts "Error publishing metrics for #{type}: #{e}"
    end
  end
end

def sample(category, *metrics)
  category, metrics = category if category.is_a? Array # sample may be passed the single yield variable of Hash#each
  metrics = [ metrics ] unless metrics.is_a? Array
  [ category, metrics.collect { |m| Cloudscopes::Sample.new(category, m) } ]
end
