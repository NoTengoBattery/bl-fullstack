# frozen_string_literal: true

FactoryBot.define do
  names = constant_common_names('Visit')
  names_spec = constant_common_names(names.const, :spec)

  user_names = constant_common_names('User')
  user_names_spec = constant_common_names(user_names.const, :spec)

  factory names.snake, class: names.const do
    ## Attributes
    ip_address { Faker::Internet.ip_v4_address }

    ## Associations
    user factory: user_names.snake

    ## Spec factory (for repeatable tests with generated and guaranteed data)
    factory names_spec.snake do
      # Associations (spec)
      user factory: user_names_spec.snake
    end
  end
end
