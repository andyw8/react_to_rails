# frozen_string_literal: true

require "test_helper"
require "erb/formatter"

class TestReactToRails < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ReactToRails::VERSION
  end

  def test_approvals
    expected_rb = ERB::Formatter.format(File.read("approvals/pricing_component.rb"))
    expected_test_rb = ERB::Formatter.format(File.read("approvals/pricing_component_test.rb"))
    expected_erb = ERB::Formatter.format(File.read("approvals/pricing_component.html.erb"))

    convert = ReactToRails::Convert.for_path("examples/pricing.jsx", name: "Pricing")
    convert.call

    actual_rb = ERB::Formatter.format(convert.view_component_ruby_code)
    actual_test_rb = ERB::Formatter.format(convert.view_component_test_ruby_code)
    actual_erb = ERB::Formatter.format(convert.erb_template)

    assert_equal expected_rb, actual_rb
    assert_equal actual_test_rb, expected_test_rb
    assert_equal expected_erb, actual_erb
  end

  # formatted = ERB::Formatter.format <<-ERB
end
