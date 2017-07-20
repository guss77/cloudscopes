module Cloudscopes
  class Memory
    def initialize
      @@data ||= (
        raw_meminfo = File.read('/proc/meminfo')
        names_and_values = raw_meminfo.split("\n").
            map {|line| line =~ /(\w+):\s+(\d+)/ and [$1, $2.to_i] }.compact
        Hash[names_and_values]
      )
    end

    def method_missing(method, *args)
      method_name = method.to_s
      if @@data.include?(method_name)
        @@data[method_name]
      else
        super
      end
    end

    def MemAvailable
      return self.MemFree + self.Buffers + self.Cached
    end

    def MemUsed
      return self.MemTotal - self.MemFree - self.Buffers - self.Cached
    end
  end
end
