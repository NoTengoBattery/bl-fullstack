# frozen_string_literal: true

require 'factory_bot'
begin
  require(Rails.root.join('spec/support/helpers/factory_helper.rb'))
rescue StandardError
  require('support/helpers/factory_helper')
end

FactoryBot::SyntaxRunner.class_eval { include FactoryHelper }
FactoryBot::Syntax::Default::DSL.class_eval { include FactoryHelper }
