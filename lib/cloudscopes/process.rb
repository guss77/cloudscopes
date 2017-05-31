require 'etc'

module Cloudscopes

  class Process

    class SystemProcess
      def initialize(id)
        @id = id.to_i
        @@maxpid ||= File.read('/proc/sys/kernel/pid_max').to_i
        raise "Invalid system process id #{id}" unless @id > 0 && @id < @@maxpid
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

      def mem_usage_rss
        statm.strip.split(/\s+/)[1].to_i * Etc.sysconf(Etc::SC_PAGESIZE)
      end
      def mem_usage_virt
        statm.strip.split(/\s+/)[0].to_i * Etc.sysconf(Etc::SC_PAGESIZE)
      end
      alias mem_usage mem_usage_virt
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

