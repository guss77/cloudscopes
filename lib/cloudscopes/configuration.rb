module Cloudscopes

  attr_reader :should_publish, :usage_requested

  def self.init
    @opts = Cloudscopes::Options.new
    usage if usage_requested
    configuration = {}
    (@opts.files.empty?? [ STDIN ] : @opts.files.collect { |fn| File.new(fn) }).each do |configfile|
      configuration.merge! YAML.load(configfile.read)
    end
    @settings = configuration['settings']
    configuration['metrics']
  end

  def self.usage_requested
    @opts.usage
  end

  def self.should_publish
    @opts.publish != false
  end

  def self.usage
    puts "#{@opts}"
    exit 5
  end

  def self.client
    @client ||= initClient
  end

  def self.initClient
    AWS::CloudWatch.new access_key_id: @settings['aws-key'],
                          secret_access_key: @settings['aws-secret'],
                          region: @settings['region']
  end

  def self.data_dimensions
    @settings['dimensions'] || ({ 'InstanceId' => '#{ec2.instance_id}' })
  end

end