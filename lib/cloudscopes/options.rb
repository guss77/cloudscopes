require 'optparse'

module Cloudscopes

  class Options

    attr_reader :publish, :config_file

    def initialize
      @publish = true
      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] <config.yaml>\n\nOptions:"
        opts.on("-t", "dump samples to the console instead of publishing, for testing") { @publish = false }
        opts.on_tail("-?", "-h", "--help", "Show this message") do
          puts(opts)
          exit
        end
      end
      arguments = option_parser.parse!
      unless arguments.size == 1
        $stderr.puts(option_parser)
        exit 1
      end
      @config_file = arguments.first
    end
  end

end
