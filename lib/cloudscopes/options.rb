module Cloudscopes
  
  class Options

    attr_reader :publish, :usage, :files
        
    def initialize
      @publish = true
      @files = OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] [<config.yaml>]\n\nOptions:"
        opts.on("-t", "dump samples to the console instead of publishing, for testing") { @publish = false }
        opts.on_tail("-?", "-h", "--help", "Show this message") { @usage = true }
      end.parse!
    end
  end
  
end
