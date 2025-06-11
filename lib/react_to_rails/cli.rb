# frozen_string_literal: true

require "optparse"
require "fileutils"

module ReactToRails
  class CLI
    def initialize
      @options = {}
    end

    def run(args)
      remaining_args = parse_options(args)

      # Get path from positional argument
      path = remaining_args.first
      name = remaining_args[1] || "ExampleComponent"

      if path.nil? || path.empty?
        puts "Error: path argument is required"
        puts
        puts parser.help
        exit 1
      end

      convert = ReactToRails::Convert.for_path(path, name: name)
      convert.call

      # Create directory structure for namespaced components
      component_dir = File.dirname("app/components/#{convert.component_file_path}")
      FileUtils.mkdir_p(component_dir) unless component_dir == "app/components"

      File.write("app/components/#{convert.component_file_path}.rb", convert.view_component_ruby_code)
      File.write("app/components/#{convert.component_file_path}.html.erb", convert.erb_template)
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
        opts.banner = "Usage: react_to_rails [options] <path> [name]"
        opts.separator ""
        opts.separator "Arguments:"
        opts.separator "  path                         Path to React components (required)"
        opts.separator "  name                         Component name (optional, defaults to ExampleComponent)"
        opts.separator "                               Supports namespaced names like Commerce::PricingComponent"
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
        opts.separator "  react_to_rails pricing.jsx"
        opts.separator "  react_to_rails pricing.jsx PricingComponent"
        opts.separator "  react_to_rails pricing.jsx Commerce::PricingComponent"
        opts.separator "  react_to_rails pricing.jsx Admin::Dashboard::Widget"
      end
    end
  end
end
