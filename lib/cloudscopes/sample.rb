module Cloudscopes
  
  class Sample
    
    attr_reader :name, :value, :unit
    
    def dimensions
      Cloudscopes.data_dimensions.collect do |key,value|
        begin
          if ! value.start_with?('"') and value.include?('#') # user wants to expand a string expression, but can't be bothered with escaping double quotes
            { name: key, value: Cloudscopes.get_binding.eval('"' + value + '"') }
          else
            { name: key, value: Cloudscopes.get_binding.eval(value) }
          end
        rescue NameError # assume the user meant to send the static text
          { name: key, value: value }
        end
      end
    end
    
    def initialize(namespace, metric)
      @name = metric['name']
      @unit = metric['unit']
      @value = nil
      
      begin
        return if metric['requires'] and ! Cloudscopes.get_binding.eval(metric['requires']) 
        @value = Cloudscopes.get_binding.eval(metric['value'])
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
      data[:dimensions] = dimensions
      data
    end
    
  end
  
end
