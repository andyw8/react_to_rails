# frozen_string_literal: true

require "optparse"

module ReactToRails
  class CLI
    def initialize
      @options = {}
    end

    def run(args)
      parse_options(args)

      if @options[:path].nil? || @options[:path].empty?
        puts "Error: path option is required"
        puts
        puts parser.help
        exit 1
      end

      # TODO: Add your main logic here
      puts "Converting React components at path: #{@options[:path]}"
    rescue OptionParser::InvalidOption => e
      puts "Error: #{e.message}"
      puts
      puts parser.help
      exit 1
    end

    private

    def parse_options(args)
      parser.parse!(args)
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: react_to_rails [options]"
        opts.separator ""
        opts.separator "Options:"

        opts.on("-p", "--path PATH", String, "Path to React components (required)") do |path|
          @options[:path] = path
        end

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
        opts.separator "  react_to_rails --path ./src/components"
        opts.separator "  react_to_rails -p /path/to/react/files"
      end
    end
  end
end
