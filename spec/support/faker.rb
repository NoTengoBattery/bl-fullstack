# frozen_string_literal: true

RSpec.configure do |config|
  Faker::Config.random = Random.new(config.seed)
  puts "\nFaker using seed #{Faker::Config.random.seed}\n"
  config.before(:all) do
    Faker::Config.random = Random.new(config.seed)
    Faker::UniqueGenerator.clear
  end
end
