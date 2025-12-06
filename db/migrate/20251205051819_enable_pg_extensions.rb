# frozen_string_literal: true

# Migration to enable required PostgreSQL extensions.
class EnablePgExtensions < ActiveRecord::Migration[8.1]
  def change
    enable_extension('pgcrypto')
    enable_extension('citext')
    enable_extension('unaccent')
    enable_extension('pg_trgm')
  end
end
