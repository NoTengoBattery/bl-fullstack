# frozen_string_literal: true

FactoryBot.define do
  names = constant_common_names('User')
  names_spec = constant_common_names(names.const, :spec)

  factory names.snake, class: names.const do
    ## Traits
    # Librarian role
    trait(:librarian) do
      role { :librarian }
    end
    # Member role
    trait(:member) do
      role { :member }
    end

    ## Attributes
    password { Faker::Internet.password(min_length: 8) }
    password_confirmation { password }
    role { nullable(present_ratio: 0.1) { :librarian } || :member }
    sequence(:email_address) { Faker::Internet.email(name: "#{role}#{it}") }

    ### Factory spec (for repeatable tests with generated and guaranteed data)
    factory names_spec.snake do
      password { 'testpass' }
      password_confirmation { 'testpass' }
    end
  end
end
