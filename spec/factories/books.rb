# frozen_string_literal: true

FactoryBot.define do
  names = constant_common_names('Book')
  names_spec = constant_common_names(names.const, :spec)

  factory names.snake, class: names.const do
    ## Attributes
    author { Faker::Book.author }
    discarded_at { nullable(present_ratio: 0.1) { Faker::Time.backward(days: 30) } }
    genre { Faker::Book.genre }
    total_copies { random_range(1..10).begin }

    ## Sequences
    sequence(:isbn) { nullable(present_ratio: 0.9) { Faker::Code.isbn.delete('-')[0..12] + it.to_s } }
    sequence(:title) { "#{Faker::Book.title} #{it}" }

    ## Traits
    # Without ISBN
    trait :without_isbn do
      isbn { nil }
    end
    # Single copy
    trait :single_copy do
      total_copies { 1 }
    end
    # Multiple copies
    trait :multiple_copies do
      total_copies { 5 }
    end
    # No copies available
    trait :no_copies do
      total_copies { 0 }
    end
    # Discarded book (soft-deleted)
    trait :discarded do
      discarded_at { Time.current }
    end
    # Kept book (not soft-deleted) - matches Discard gem terminology
    trait :kept do
      discarded_at { nil }
    end

    ### Factory spec (for repeatable tests with generated and guaranteed data)
    factory names_spec.snake do
      total_copies { 1 }
    end
  end
end
