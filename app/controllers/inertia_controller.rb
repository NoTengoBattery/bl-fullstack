# frozen_string_literal: true

class InertiaController < ApplicationController
  layout 'inertia'

  inertia_share flash: -> { flash.to_hash }
end
