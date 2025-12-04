# frozen_string_literal: true

class InertiaExampleController < InertiaController
  def index
    render inertia: 'inertia_example/index', props: {
      rails_version: Rails.version,
      ruby_version: RUBY_DESCRIPTION,
      rack_version: Rack.release,
      inertia_rails_version: InertiaRails::VERSION,
    }
  end
end
