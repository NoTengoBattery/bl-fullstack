# frozen_string_literal: true

RSpec.configure do |config|
  Faker::Config.random = Random.new(config.seed)

  config.before(:all) do
    Faker::Config.random = Random.new(config.seed)
    Faker::UniqueGenerator.clear
  end
end
