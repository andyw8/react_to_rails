# app/components/pricing_component.rb
class PricingComponent < ViewComponent::Base
  def initialize(tiers:)
    @tiers = tiers
  end
end
