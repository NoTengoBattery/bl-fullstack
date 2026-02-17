# frozen_string_literal: true

# Controller for the about page.
# Shows information about this template.
class AboutController < ApplicationController
  def index
    render(inertia: 'about/index')
  end
end
