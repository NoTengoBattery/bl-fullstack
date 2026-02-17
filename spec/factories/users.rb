# frozen_string_literal: true

FactoryBot.define do
  names = constant_common_names('User')
  names_spec = constant_common_names(names.const, :spec)

  factory names.snake, class: names.const do
    ## Attributes
    password { Faker::Internet.password(min_length: 8) }
    password_confirmation { password }
    sequence(:email_address) { Faker::Internet.email(name: "user#{it}") }

    ### Factory spec (for repeatable tests with generated and guaranteed data)
    factory names_spec.snake do
      password { 'testpass' }
      password_confirmation { 'testpass' }
    end
  end
end
