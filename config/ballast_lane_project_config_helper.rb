# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'concurrent-ruby'

# Helper module for calculating pool sizes and configuration values.
# Used for database, cache, and worker configuration.
module BallastLaneProjectConfigHelper
  # Calculates the pool size for different services based on environment variables

  def self.cache_pool = calculate_pool('CACHE_POOL_SIZE')
  def self.database_pool = calculate_pool('DATABASE_POOL_SIZE')
  def self.kvdb_pool = calculate_pool('KVDATABASE_POOL_SIZE')
  def self.max_threads = sidekiq_server? ? sidekiq_threads : rails_threads
  def self.rails_threads = numerify(ENV['RAILS_MAX_THREADS'].presence)
  def self.sidekiq_threads = numerify(ENV['SIDEKIQ_THREADS'].presence)

  def self.worker_check_interval = numerify(ENV['PUMA_WORKER_CHECK_INTERVAL'].presence, default: 1)

  def self.worker_count = numerify(ENV['WEB_CONCURRENCY'].presence, default: default_worker_count)

  def self.worker_timeout = numerify(ENV['PUMA_WORKER_TIMEOUT'].presence, default: 3)

  # Adjusts pool size considering Sidekiq server presence
  def self.adjusted_pool_size(env_pool) = numerify(env_pool) + (sidekiq_server? ? 2 : 0)

  # Determines the appropriate pool size based on the environment variable
  def self.calculate_pool(env_var)
    env_pool = ENV[env_var].presence
    return adjusted_pool_size(env_pool) if env_pool

    default_pool_size
  end

  # Calculates default pool size based on server type
  def self.default_pool_size = (max_threads + adjusted_pool_size(1)) * 2

  def self.default_worker_count = [Concurrent.processor_count, 1].max

  # Ensures the value is a valid integer and not less than 1
  def self.numerify(value, min: 1, default: 1)
    return default if value.blank?

    [value.to_i, min].max
  end

  def self.sidekiq_server?
    defined?(Sidekiq) && Sidekiq.respond_to?(:server?) && Sidekiq.server?
  end
end
