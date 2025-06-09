# frozen_string_literal: true

require "optparse"

module ReactToRails
  class CLI
    def initialize
      @options = {}
    end

    def run(args)
      remaining_args = parse_options(args)

      # Get path from positional argument
      path = remaining_args.first

      if path.nil? || path.empty?
        puts "Error: path argument is required"
        puts
        puts parser.help
        exit 1
      end

      # TODO: Add your main logic here
      puts "Converting React component at path: #{path}"
    rescue OptionParser::InvalidOption => e
      puts "Error: #{e.message}"
      puts
      puts parser.help
      exit 1
    end

    private

    def parse_options(args)
      parser.parse!(args)
      args # Return remaining arguments after parsing options
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: react_to_rails [options] <path>"
        opts.separator ""
        opts.separator "Arguments:"
        opts.separator "  path                         Path to React components (required)"
        opts.separator ""
        opts.separator "Options:"

        opts.on("-h", "--help", "Show this help message") do
          puts opts
          exit
        end

        opts.on("-v", "--version", "Show version") do
          puts ReactToRails::VERSION
          exit
        end

        opts.separator ""
        opts.separator "Examples:"
        opts.separator "  react_to_rails ./src/components"
        opts.separator "  react_to_rails /path/to/react/files"
      end
    end
  end
end
