# React To Rails

This gem converts React components to Rails [View Components](https://viewcomponent.org) using AI.

## Background

I created this tool for use with [Tailwind Plus](https://tailwindcss.com/plus/) (formerly Tailwind UI).

Tailwind Plus is a commercial product which provides high quality components for React and Vue.

There are also plain HTML versions but they are awkward to work with for Rails, e.g.:

- You need to add ERB `<%= %>` placeholders for any content you're passing in.
- The HTML is static so is missing any loops, conditionals, etc
- Icons are converted to verbose SVG markup

This tool generates a View Component based on the supplied React component which should be much more convenient for Rails.

It's likely that you'll need to still do _some_ work, but it should save a lot of time.

For more details of the conversion process, you can look at the [prompt](./lib/react_to_rails/convert.rb).

# Demo

Here is an example of the free [Two tiers with emphasized tier](https://tailwindcss.com/plus/ui-blocks/marketing/sections/pricing) component.

Initial steps.

- Select React in the dropdown
- Switch to the Code view
- Click the Copy icon
- Paste that into a new file in your editor
- Save it to disk, e.g. `pricing.jsx`.

Now convert it by running:

`react_to_rails pricing.jsx PricingComponent`

The tool will output a report, and generate the view component files:

```
**Notes on the conversion:**

- The `@headlessui/react` library is not used, so no issues there.
- The `CheckIcon` from `@heroicons/react` is replaced with the `heroicon` helper.
- The `classNames` function is replaced with the `class_names` helper.
- The `tiers` array is converted to a Ruby array of hashes and should be passed in as a parameter to the component.
- `<a href>` is replaced with `link_to`.
- All Tailwind classes are preserved as-is.
- No JavaScript or interactivity is present, so no need for Stimulus or Turbo.
- No `<img>`, `<form>`, or `<button>` tags are present.
- The `style` attribute for the background div is converted to a Ruby hash in ERB.
- The ERB demo file shows how to pass the `tiers` array to the component.
- All logic and conditional classes are preserved using Ruby and ERB.
- No parts were impossible to convert.

### EXAMPLE USAGE ###

<%# app/views/demo/index.html.erb %>
<% tiers = [
  {
    name: 'Hobby',
    id: 'tier-hobby',
    href: '#',
    price_monthly: '$29',
    description: "The perfect plan if you're just getting started with our product.",
    features: ['25 products', 'Up to 10,000 subscribers', 'Advanced analytics', '24-hour support response time'],
    featured: false,
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
      'Custom integrations',
    ],
    featured: true,
  }
] %>

<%= render(PricingComponent.new(tiers: tiers)) %>
```

And here is the generated code:

* [app/component/pricing_component.html.erb](./examples/pricing_component.html.erb).
* [app/components/pricing_component.rb](./examples/pricing_component.rb)

## Limitations

Components that make use of JavaScript will need further work, e.g to use Stimulus instead.

## Prerequisites

Your app must be set up with:

* [view_component](https://viewcomponent.org)
* [heroicons](https://github.com/jclusso/heroicons)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add react_to_rails
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install react_to_rails
```

## Setup

You will need to provide an OpenAI API key. If you need to create a key, you can do so in the OpenAI [settings](https://platform.openai.com/settings).

The gem looks for an `OPENAI_API_KEY` in the environment (or you can pass it directly with `OPEN_API_KEY=... react_to_erb`).

## Usage

Save the React JSX file, then use the command line tool to create a new view component with the given name, e.g.:

```bash
react_to_rails pricing.jsx PricingComponent
```

Options:
- `-h, --help` - Show help message
- `-v, --version` - Show version



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andyw8/react_to_rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
