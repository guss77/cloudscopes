module Cloudscopes

  class << self
    def init
      @opts = Cloudscopes::Options.new
      configuration = {}
      (@opts.files.empty?? [ STDIN ] : @opts.files.collect { |fn| File.new(fn) }).each do |configfile|
        configuration.merge! YAML.load(configfile.read)
      end
      @settings = configuration['settings']
      configuration['metrics']
    end

    def should_publish
      @opts.publish
    end

    def client
      @client ||= initClient
    end

    def initClient
      AWS::CloudWatch.new access_key_id: @settings['aws-key'],
                            secret_access_key: @settings['aws-secret'],
                            region: @settings['region']
    end

    def data_dimensions
      @settings['dimensions'] || ({ 'InstanceId' => '#{ec2.instance_id}' })
    end
  end
end
