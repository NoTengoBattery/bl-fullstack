# frozen_string_literal: true

module ConstantCommonNames
  module_function

  def resolve_constant(name, suffix)
    full_name = "#{name.to_s.camelize}#{suffix.to_s.camelize}"
    candidates = [full_name, "::#{full_name}"]
    constant = candidates.lazy.filter_map { safe_constantize(it) }.first
    constant ? [constant, constant.name, "::#{constant.name}"] : [nil, full_name, nil]
  end

  def safe_constantize(str)
    str.constantize
  rescue StandardError
    nil
  end

  def normalize_input(input)
    return input unless input.is_a?(String)

    input.constantize
  rescue NameError => e
    raise unless e.message.include?('wrong constant name') || e.message.include?('uninitialized constant')

    input
  end

  def extract_name(input) = input.is_a?(Module) ? input.name : input

  def build_names_hash(class_name, constant, qualified_path)
    {
      camel: class_name,
      const: constant,
      env: class_name.delete(':').underscore.upcase,
      human: class_name.humanize.downcase,
      path: qualified_path,
      route: class_name.underscore.tr('/', '~'),
      snake: class_name.underscore,
      uri_safe: class_name.parameterize
    }.deep_transform_values! { it.is_a?(String) ? it.deep_freeze : it }
  end

  def build_struct(class_name, names)
    struct_name = "Ꚛ#{class_name.gsub('::', 'Ꚛ')}Ꚛ"
    struct_class = safe_constantize("::Struct::#{struct_name}") || Struct.new(struct_name, *names.keys.sort!)
    struct_class.new(**names).deep_freeze
  end

  def call(input, suffix = '')
    input = normalize_input(input)
    raw_name = extract_name(input)
    raise(ArgumentError) unless raw_name.is_a?(String) || raw_name.is_a?(Symbol)

    cache_key_id = input.is_a?(Module) ? input.object_id : SecureRandom.alphanumeric
    CacheKey.memoize!(input, cache_key_id, suffix) do
      constant, class_name, qualified_path = resolve_constant(raw_name, suffix)
      demodulized = class_name.demodulize
      names = build_names_hash(class_name, constant, qualified_path)

      unless demodulized == class_name
        names[:name] = call(demodulized)
        names[:namespace] = call(class_name.deconstantize)
      end

      build_struct(class_name, names)
    end
  end
end

def constant_common_names(klass, suffix = '') = ConstantCommonNames.call(klass, suffix)
