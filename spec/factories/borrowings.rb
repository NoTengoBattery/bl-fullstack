# frozen_string_literal: true

FactoryBot.define do
  names = constant_common_names('Borrowing')
  names_spec = constant_common_names(names.const, :spec)

  user_names = constant_common_names('User')
  user_names_spec = constant_common_names(user_names.const, :spec)

  book_names = constant_common_names('Book')
  book_names_spec = constant_common_names(book_names.const, :spec)

  factory names.snake, class: names.const do
    ## Transients
    transient do
      should_be_returned { Faker::Boolean.boolean(true_ratio: 0.4) }
      should_be_overdue { Faker::Boolean.boolean(true_ratio: 0.15) }
    end

    ## Associations
    user factory: user_names.snake
    book factory: book_names.snake

    ## Fields
    borrowed_at { Time.current }
    status { should_be_returned ? :returned : :active }
    returned_at { Faker::Time.between(from: borrowed_at, to: Time.current) if should_be_returned }

    due_on do
      if should_be_overdue
        Faker::Date.between(from: 2.weeks.ago, to: 1.day.ago)
      else
        2.weeks.from_now.to_date
      end
    end

    ## Guaranteed status traits
    # Active borrowing (not returned)
    trait :active do
      status { :active }
      returned_at { nil }
    end
    # Returned borrowing
    trait :returned do
      status { :returned }
      returned_at { Time.current }
    end
    # Overdue active borrowing
    trait :overdue do
      status { :active }
      due_on { 1.week.ago.to_date }
      returned_at { nil }
    end
    # Due soon
    trait :due_soon do
      due_on { 2.days.from_now.to_date }
    end

    ## Spec factory (for repeatable tests with generated and guaranteed data)
    factory names_spec.snake do
      # Associations (spec)
      user factory: user_names_spec.snake
      book factory: book_names_spec.snake
    end
  end
end
