# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

Object.class_eval { def deep_freeze = tap { Ractor.make_shareable(it) } }

require 'bundler/setup' # Set up gems listed in the Gemfile.
require_relative 'ballast_lane_project_config_helper' # Load project configuration helper
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
