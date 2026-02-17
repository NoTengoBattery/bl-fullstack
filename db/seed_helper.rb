# frozen_string_literal: true

SEEDER_RETRY_TIMES = 3
SEEDER_DEFAULT_RECORDS = 10

Rails.logger.level = :debug

def seed_model(
  model:, factory: '', factory_opts: [], factory_kw: {},
  retries: SEEDER_RETRY_TIMES, times: SEEDER_DEFAULT_RECORDS
)
  names = constant_common_names(model)
  snake, model = names.to_h.values_at(:snake, :const)
  failure = retries

  iterations = ENV.fetch("#{names.env}_TIMES", times) - model.count
  iterations.times do |itr|
    new_model = FactoryBot.build((factory.presence || snake).to_sym, *factory_opts, **factory_kw)
    yield(new_model) if block_given?

    new_model.save!
    Rails.logger.info { "+>> Created new #{model} id:#{new_model.id} [#{itr + 1}]" }
    puts("Created #{model}: #{itr + 1} out of #{iterations}") unless Rails.env.test? # rubocop:disable Rails/Output
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    Rails.logger.warn { "~>> Failed to store new #{model} [#{itr + 1}], retry: #{failure}" }
    Rails.logger.ap(new_model, level: :warn, sort_keys: true, color: nil)
    Rails.logger.warn { '--->>>' }
    Rails.logger.error { e.message }
    e.backtrace.each { |line| Rails.logger.error { line } }
    ((failure -= 1) <= 0) ? ((failure = SEEDER_RETRY_TIMES) && next) : redo
  end
end
