# frozen_string_literal: true

APPLICATION_NAME = ENV.fetch('APPLICATION_NAME').deep_freeze

CREDENTIALS = Rails.application.credentials.config.deep_dup.deep_freeze
MESSAGE_ENCRYPTOR = ActiveSupport::MessageEncryptor.new(CREDENTIALS.fetch(:secret_key_base)[0..31])

module Digest
  module UUID
    NULL = '00000000-0000-0000-0000-000000000000'.deep_freeze
    NULL_V4 = '00000000-0000-4000-8000-000000000000'.deep_freeze
    REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i ### TODO
  end
end
