# frozen_string_literal: true

# Controller for the home page.
# Shows a hello world message and login visit count.
class HomeController < ApplicationController
  def index
    visits = current_user&.visits&.order(created_at: :desc) || Visit.none
    visit_count = visits.count

    render(inertia: 'home/index', props: {
             message: current_user ? "Hello, #{current_user.email_address}!" : 'Hello, World!',
             visit_count:,
             visits: VisitBlueprint.render_as_hash(visits.limit(10))
           })
  end
end
