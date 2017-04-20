require 'yaml'
require 'aws-sdk'

module Cloudscopes

  class << self
    def init
      @opts = Cloudscopes::Options.new
      configuration = YAML.load(File.read(@opts.config_file))
      @settings = configuration['settings']
      @metrics = configuration['metrics'] || {}
      if metric_dir = @settings['metric_definition_dir']
        merge_metric_definitions(Dir.glob("#{metric_dir}/*").select(&File.method(:file?)))
      end
      @metrics
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

    private

    def merge_metric_definitions(files)
      files.each do |metric_file|
        YAML.load(File.read(metric_file)).each do |namespace, definitions|
          @metrics[namespace] ||= []
          @metrics[namespace] += definitions
        end
      end
    end
  end
end
