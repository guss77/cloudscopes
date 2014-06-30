##
# public API expressed through kernel (global) methods, for simplicity
#

def publish(samples)
  raise "Not running in EC2, so won't publish!" unless File.executable?("/usr/bin/ec2metadata")
  samples.each do |type,metric_samples|
    begin
      valid_data = metric_samples.select(&:valid)
      next if valid_data.empty?
      valid_data.each_slice(4) do |slice| # slice metrics to chunks - the actual limit is 20, but CloudWatch starts misbehaving if I put too much data
        Monitoring.client.put_metric_data namespace: type,
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
  [ category, metrics.collect { |m| Monitoring::Sample.new(category, m) } ]
end
