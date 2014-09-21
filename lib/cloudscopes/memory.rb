module Cloudscopes
  
  class Memory

    File.read('/proc/meminfo').split("\n").collect do |line|
      line =~ /(\w+):\s+(\d+)/ and { name: $1, value: $2.to_i } 
    end.each do |data|
      next if data.nil? 
      define_method(data[:name]) { data[:value] }
    end

  end
  
end
