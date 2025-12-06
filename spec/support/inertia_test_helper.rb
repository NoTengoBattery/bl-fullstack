# frozen_string_literal: true

module InertiaTestHelper
  # Returns the Inertia page data from the response
  def inertia_page
    return nil unless response.media_type == 'text/html'

    # For HTML responses, parse the data-page attribute from the response body
    match = response.body.match(/data-page="([^"]*)"/)
    return nil unless match

    JSON.parse(CGI.unescapeHTML(match[1]))
  end

  # Returns the component name from the Inertia response
  def inertia_component
    inertia_page&.dig('component')
  end

  # Returns the props from the Inertia response
  def inertia_props
    inertia_page&.dig('props')
  end

  # Matcher helper for checking Inertia component
  def expect_inertia_component(component_name)
    expect(inertia_component).to(eq(component_name))
  end
end

RSpec.configure do |config|
  config.include(InertiaTestHelper, type: :request)
end
