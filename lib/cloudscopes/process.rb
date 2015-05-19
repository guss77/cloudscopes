require 'etc'

module Cloudscopes
  
  class Process
    
    class SystemProcess
      def initialize(id)
        @id = id.to_i
        raise "Invalid system process id #{id}" unless @id > 0 && @id <= 65536
      end
      
      def procpath(field = nil)
        "/proc/#{@id}/#{field}"
      end
      
      def exe
        begin
          File.readlink(procpath('exe'))
        rescue SystemCallError => e # report and ignore
          $stderr.puts "Error accessing process #{@id}: #{e.message}"
          ''
        end
      end
      
      def exe_name
        File.basename(exe)
      end
      
      def uid
        File.stat(procpath('mem')).uid
      end
      
      def user
        Etc.getpwuid(uid).name
      end
    end
    
    def list
      Dir["/proc/[0-9]*[0-9]"].collect{|dir| SystemProcess.new(File.basename(dir).to_i) }
    end
    
  end
  
end

