module Cloudscopes
  
  class System
    
    def loadavg5
      File.read("/proc/loadavg").split(/\s+/).first.to_f
    end
    
    def cpucount
      File.read("/proc/cpuinfo").split("\n").grep(/^processor\s+/).count
    end
    
    # Read https://www.kernel.org/doc/Documentation/ABI/testing/procfs-diskstats for the field meanings
    # this method returns fields 4~14 as sum for all devices (as array indexes 0..10)
    def iostat
      File.read("/proc/diskstats").split("\n").collect do |dev|
        dev.gsub(/^\s+/,"").split(/\s+/)[3..13].collect(&:to_i) 
      end.inject() do |sums,vals| 
        sums ||= vals.collect { 0 } # init with zeros
        sums.zip(vals).map {|a| a.reduce(:+) } # sum array values
      end
    end
    
    def service(name)
      %x(PATH=/usr/sbin:/usr/bin:/sbin:/bin /usr/sbin/service #{name} status 2>/dev/null)
      $?.exitstatus == 0
    end
    
    def bluepill_ok?(name)
      %x(/usr/local/bin/bluepill wfs status).split("\n").
        select { |ln| ln =~ /pid:/ }.
        collect { |ln| ln =~ /pid:(\d+).*:\s*(.*)/ and { pid: $1, status: $2 } }.
        all? { |proc| proc[:status] == "up"}
    end
    
  end
  
  def self.system # must define, otherwise kernel.system matches
    System.new
  end
  
end

