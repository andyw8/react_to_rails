# frozen_string_literal: true

require "zeitwerk"

module ReactToRails
  class Error < StandardError; end

  # Set up Zeitwerk autoloader
  loader = Zeitwerk::Loader.for_gem
  loader.inflector.inflect("cli" => "CLI")
  loader.setup
end
