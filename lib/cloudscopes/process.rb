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
      
      def method_missing(name, *args)
        raise ArgumentError.new("wrong number of arguments (#{args.length} for 0)") unless args.length == 0
        begin
          File.read(procpath(name.to_s))
        rescue Errno::ENOENT => e # ignore kernel threads
          ''
        rescue SystemCallError => e # report and ignore
          $stderr.puts "Error accessing process #{@id}: #{e.class}:#{e.message}"
          ''
        end
      end
      
      def exe
        begin
          File.readlink(procpath('exe'))
        rescue Errno::ENOENT => e # ignore kernel threads
          ''
        rescue SystemCallError => e # report and ignore
          $stderr.puts "Error accessing process #{@id}: #{e.class}:#{e.message}"
          ''
        end
      end
      
      def exe_name
        File.basename(exe)
      end
      
      def uid
        begin
          File.stat(procpath('mem')).uid
        rescue Errno::ENOENT => e
          nil
        end
      end
      
      def user
        Etc.getpwuid(uid || 0).name
      end
      
      def mem_usage
        # lots of magic follow, peruse at your own risk
        maps.strip.split("\n").collect do |l|
          l.split(/\s+/)
        end.select do |r|
          r[4].to_i == 0 && r[1] !~ /s/
        end.collect do |r|
          b,e = r[0].split(/-/,2).collect{ |a| a.to_i(16) }
          r[0] = e - b
          r
        end.inject(0) do |s,r|
          s += r[0]
        end
      end
    end
    
    def list
      list = Dir["/proc/[0-9]*[0-9]"].collect{|dir| SystemProcess.new(File.basename(dir).to_i) }
      list.define_singleton_method(:method_missing) do |name, *args|
        case name.to_s
        when /^by_(.*)/
          field = $1.to_sym
          raise ArgumentError.new("wrong number of arguments (#{args.length} for 1)") unless args.length == 1
          select do |ps| 
            case ps.send(field)
            when args.first
              true
            else
              false
            end
          end
        else
          raise NoMethodError.new("No such method #{name}",name)
        end
      end
      list
    end
    
  end
  
end

