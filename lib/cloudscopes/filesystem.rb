module Cloudscopes
  
  module StatFs
    # The result of a statfs operation, see "man statfs" for more information
    # on each field.  We add some helper methods that deal in bytes.
    class Result < Struct.new(:type, :bsize, :blocks, :bfree, :bavail, :files, :ffree)
      def total; blocks * bsize; end
      def free; bfree * bsize; end
      def avail; bavail * bsize; end
    end
    
    module Lib
      extend FFI::Library
      ffi_lib FFI::Library::LIBC
      attach_function 'statfs64', [:string, :pointer], :int
    end
    
    # Drives the interface to the C library, returns a StatFs::Result object
    # to show filesystem information for the given path.
    #
    def self.statfs(path)
      output = FFI::MemoryPointer.new(128)
      begin
        error_code = Lib::statfs64(path, output)
        raise "statfs raised error #{error_code}" if error_code != 0
        return Result.new(*output[0].read_array_of_long(7))
      ensure
        output.free
      end
    end
  end
    
  class Filesystem
    
    @@mountpoints = File.read("/proc/mounts").split("\n").grep(/(?:xv|s)d/).collect { |l| l.split(/\s+/)[1] }
    
    def mountpoints
      @@mountpoints
    end
    
    def df(path)
      StatFs.statfs(path)
    end
    
  end

end

