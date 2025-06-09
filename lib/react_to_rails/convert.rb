# frozen_string_literal: true

require "openai"
require "json"

module ReactToRails
  class StructuredResponse < OpenAI::BaseModel
    required :summary, String, doc: "A summary of what was done"
    required :erb_template, String
    required :view_component_ruby_code, String
    required :demo_erb_code, String
  end

  class Convert
    def initialize(react_content, client:, name:)
      @react_content = react_content
      @client = client
      @name = name
    end

    def self.for_path(path, client:, name:)
      react_content = File.read(path)
      new(react_content, client: client, name: name).call
    end

    def call
      puts "### PROMPT ###"
      puts
      puts prompt
      puts
      puts "Waiting for OpenAI to respond..."

      response = client.responses.create(
        model: :"gpt-4.1",
        temperature: 0,
        input: [
          {role: "user", content: prompt}
        ],
        text: StructuredResponse
      )

      puts "### RESPONSE ###"

      response = JSON.parse(response.output.first.content.first.to_json).fetch("parsed")

      @summary = response.fetch("summary")
      @view_component_ruby_code = response.fetch("view_component_ruby_code")
      @erb_template = response.fetch("erb_template")
      @demo_erb_code = response.fetch("demo_erb_code")

      component_file_name = @name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
      File.write("app/components/#{component_file_name}.rb", @view_component_ruby_code)
      File.write("app/components/#{component_file_name}.html.erb", @erb_template)
      puts @summary
      puts
      puts "### EXAMPLE USAGE ###"
      puts
      puts @demo_erb_code
    end

    private

    def prompt
      <<~EOS
        You are a professional Ruby on Rails developer.

        Convert this React JSX component into a View Component for use with Ruby on Rails.

        The component should be named: #{@name}

        The view component consists of two files.

        The first is a Ruby file, like this:

        ```
        # app/components/message_component.rb
        class MessageComponent < ViewComponent::Base
          def initialize(name:)
            @name = name
          end
        end
        ```

        The other is an ERB template, like this:

        ```
        <%# app/components/message_component.html.erb %>
        <h1>Hello, <%= @name %>!<h1>
        ```

        Also provide the source for an ERB demo file showing one example use of the component, e.g.:

        ```
        <%# app/views/demo/index.html.erb %>

        <% name = "World" %>

        <%= render(MessageComponent.new(name: name)) %>
        ```

        Notes:

        * If the code contains components from `@headlessui/react' then explain that is not supported and don't attempt to convert.
        * Don't attempt to verify Tailwind class names, assume they are valid.
        * Keep single-line ternary conditions as single-line ternary.
        * The React code may contain an array of example objects before the markup. Preserve this, but convert it to an array of Ruby hashes in the ERB demo file. And change camelCase keys to snake_case.
        * Replace `<img>` tags with Rails `image_tag` helper calls.
        * Replace `<a href>` tags with Rails `link_to` helper calls. Preserve all CSS utility classes as-is, and assume Tailwind is available.
        * Replace `<form>` tags with Rails `form_tag` helper calls.
        * Replace `<button>` tags with Rails `buton_tag` helper calls.
        * Replace `onClick` events with theoretical Stimulus calls.
        * Assume a heroicons helper is available, e.g.: <%= heroicon "magnifying-glass", options: { class: "text-primary-500" } %>
        * Asssume a `class_names` helper is available which works just like React's `classNames` helper.
        * If the component relies on client-side behaviour, suggest to use Stimulus or Turbo instead. Also provide https://github.com/excid3/tailwindcss-stimulus-components as a reference.
        * If the code constains instructions such as "This example requires updating your template" then report those details.
        * Don't add HTML comment that weren't in the original.
        * Let me know if any parts were not possible to accurately convert.

        ```
        #{react_content}
        ```
      EOS
    end

    attr_reader :react_content, :client, :name, :summary, :view_component_ruby_code, :demo_erb_code, :erb_template
  end
end
