# frozen_string_literal: true

module FactoryHelper
  def nullable(present_ratio: 0.5)
    Faker::Boolean.boolean(true_ratio: present_ratio) ? yield : nil
  end

  def random_range(range = (0..100))
    values = [Faker::Number.within(range:), Faker::Number.within(range:)].sort!
    Range.new(values[0], values[1], exclude_end: true)
  end

  def factory_names(class_list = [], suffix: nil, defined: false)
    class_list
      .map { |klass| constant_common_names(klass).const }
      .compact_blank
      .select { |klass| klass.ancestors.map(&:name).include?('ApplicationRecord') }
      .map { |klass| constant_common_names(klass, suffix).snake }
      .select { |factory_name| defined ? FactoryBot.factories.registered?(factory_name) : true }
  end

  def find_in_database(context, unique_by)
    overrides = context.instance_variable_get(:@overrides)
    find_by_attributes = overrides.transform_values do |value|
      value.respond_to?(:id) ? value.id : value
    end.slice(*Array.wrap(unique_by))

    instance = context.instance
    found_record = instance.class.find_by(**find_by_attributes)

    update_instance_from_database(instance, found_record) if instance.present? && found_record.present?
  end

  def interface_models(interface)
    ApplicationRecord.descendants.select { |model| model.include?(interface) }
  end

  private

  def update_instance_from_database(instance, found_record)
    instance.id = found_record.id
    instance.reload
  end
end
