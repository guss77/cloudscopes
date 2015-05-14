module Cloudscopes
  
  class Process
    
    class SystemProcess
      def initialize(id)
        @id = id.to_i
        raise "Invalid system process id #{id}" unless @id > 0 && @id <= 65536
      end
      
      def exe
        begin
          File.readlink("/proc/#{@id}/exe")
        rescue SystemCallError => e # report and ignore
          $stderr.puts "Error accessing process #{@id}: #{e.message}"
          ''
        end
      end
      
      def exe_name
        File.basename(exe)
      end
    end
    
    def list
      Dir["/proc/[0-9]*[0-9]"].collect{|dir| SystemProcess.new(File.basename(dir).to_i) }
    end
    
  end
  
end

