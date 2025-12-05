# frozen_string_literal: true

require_relative '../../lib/extra/factory_bot_syntax'

RSpec.configure do |config|
  config.include(FactoryBot::Syntax::Methods)
  config.include(FactoryHelper)
end
