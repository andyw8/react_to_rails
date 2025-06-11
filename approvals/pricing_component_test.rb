require "test_helper"

class PricingComponentTest < ActiveSupport::TestCase
  include ViewComponent::TestHelpers

  test "it renders pricing tiers correctly" do
    tiers = [
      {
        name: 'Hobby',
        id: 'tier-hobby',
        href: '#',
        price_monthly: '$29',
        description: "The perfect plan if you're just getting started with our product.",
        features: ['25 products', 'Up to 10,000 subscribers', 'Advanced analytics', '24-hour support response time'],
        featured: false
      },
      {
        name: 'Enterprise',
        id: 'tier-enterprise',
        href: '#',
        price_monthly: '$99',
        description: 'Dedicated support and infrastructure for your company.',
        features: [
          'Unlimited products',
          'Unlimited subscribers',
          'Advanced analytics',
          'Dedicated support representative',
          'Marketing automations',
          'Custom integrations'
        ],
        featured: true
      }
    ]
    render_inline(PricingComponent.new(tiers: tiers))
    assert_selector "h2", text: "Pricing"
    assert_selector "h3", text: "Hobby"
    assert_selector "h3", text: "Enterprise"
    assert_selector "span", text: "$29"
    assert_selector "span", text: "$99"
    assert_selector "a", text: "Get started today"
  end
end
