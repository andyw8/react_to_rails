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

  class Client
    def initialize(openai_client: nil)
      @openai_client = openai_client || OpenAI::Client.new
    end

    def call(prompt)
      response = openai_client.responses.create(
        model: :"gpt-4.1",
        temperature: 0,
        input: [
          {role: "user", content: prompt}
        ],
        text: StructuredResponse
      )

      JSON.parse(response.output.first.content.first.to_json).fetch("parsed")
    end

    private

    attr_reader :openai_client
  end

  class Convert
    attr_reader :react_content, :client, :name, :summary, :view_component_ruby_code, :demo_erb_code, :erb_template

    def initialize(react_content, name:, client: nil)
      @react_content = react_content
      @name = name
      @client = client || Client.new
    end

    def self.for_path(path, name:)
      react_content = File.read(path)
      new(react_content, name: name)
    end

    def call
      puts "### PROMPT ###"
      puts
      puts prompt
      puts
      puts "Waiting for OpenAI to respond..."

      response = Client.new.call(prompt)

      @summary = response.fetch("summary")
      @view_component_ruby_code = response.fetch("view_component_ruby_code")
      @erb_template = response.fetch("erb_template")
      @demo_erb_code = response.fetch("demo_erb_code")

      puts @summary

      return if @erb_template == "" || @view_component_ruby_code == ""

      puts
      puts "### EXAMPLE USAGE ###"
      puts
      puts @demo_erb_code
    end

    def component_file_name
      class_name = @name.split('::').last
      # Remove existing "Component" suffix if present, then add it back
      base_name = class_name.sub(/Component$/, '')
      base_name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase + "_component"
    end

    def component_file_path
      parts = @name.split('::')
      namespace_path = parts[0..-2].map(&:downcase).join('/')
      class_name = parts.last
      # Remove existing "Component" suffix if present, then add it back
      base_name = class_name.sub(/Component$/, '')
      file_name = base_name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase + "_component"
      
      if namespace_path.empty?
        file_name
      else
        "#{namespace_path}/#{file_name}"
      end
    end

    def full_component_class_name
      parts = @name.split('::')
      namespace = parts[0..-2].join('::')
      class_name = parts.last
      # Remove existing "Component" suffix if present, then add it back
      base_name = class_name.sub(/Component$/, '')
      full_class_name = base_name + "Component"
      
      if namespace.empty?
        full_class_name
      else
        "#{namespace}::#{full_class_name}"
      end
    end

    private

    def prompt
      <<~EOS
        You are a professional Ruby on Rails developer.

        Convert this React JSX component into a View Component for use with Ruby on Rails.

        The component should be named: #{full_component_class_name}

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

        For namespaced components, wrap the class in the appropriate module:

        ```
        # app/components/commerce/message_component.rb
        module Commerce
          class MessageComponent < ViewComponent::Base
            def initialize(name:)
              @name = name
            end
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
        * Assume a `class_names` helper is available which works just like React's `classNames` helper.
        * If the component relies on client-side behaviour, suggest to use Stimulus or Turbo instead. Also provide https://github.com/excid3/tailwindcss-stimulus-components as a reference.
        * If the code constains instructions such as "This example requires updating your template" then report those details.
        * Don't add HTML comment that weren't in the original.
        * Let the user know if any parts were not possible to accurately convert.
        * If `html_safe` is used then warn the user to check for potential security issues.

        ```
        #{react_content}
        ```
      EOS
    end
  end
end
