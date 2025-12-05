# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if ENV['SKIP_SEEDS'] == 'true'
  Rails.logger.info { 'Skipping seeder...' }

  return
end

require 'faker'

require Rails.root.join('lib/extra/factory_bot_syntax.rb')
Rails.root.glob('spec/support/helpers/**/*.rb').sort.each { require(it) }
begin
  require('factory_bot_rails')
rescue StandardError
  nil
end

include FactoryHelper # rubocop:disable Style/MixinUsage

# Patch ActiveRecord::Relation for a faster get to get a random record from the DB
ActiveRecord::Relation.class_eval do
  def random_sample = order(Arel.sql('RANDOM()')).limit(1).take
end

Rails.root.glob("db/#{Rails.env}-seeds/*.rb").sort.each do |file|
  Rails.logger.info do
    "~~> Processing seed: #{File.basename(file)}".tap { puts(it) unless Rails.env.test? } # rubocop:disable Rails/Output
  end
  load file
end
