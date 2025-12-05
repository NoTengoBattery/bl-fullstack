# frozen_string_literal: true

# CacheKey is a fully customized module that calculates cache keys that expire when the files are modified.
#
# It acts similarly to Rail's ActionView cache but brings support for low-level caching keys. This allows using
# caching without worrying about cache versioning or stale cache keys, in most situations.
#
# Thanks to NoTengoBattery for this implementation. The original version was grabbed from his Rails 6 template.

module CacheKey
  extend self

  FAST_CACHE_SIZE = 10_000
  GIT_REVISION = `git rev-parse HEAD`.squish!.deep_freeze

  FAST_CACHE = LruRedux::Cache.new(FAST_CACHE_SIZE).freeze
  FAST_CACHE_TS = LruRedux::ThreadSafeCache.new(FAST_CACHE_SIZE).freeze

  def file_digest!(path, name)
    relpath = FAST_CACHE_TS.getset(uniform_key(path)) do
      path ? Pathname.new(path).relative_path_from(Rails.root) : (return name)
    end

    mtime = build_mtime_values(relpath)
    FAST_CACHE_TS.getset(uniform_key(relpath, *mtime)) do
      build_file_key(relpath).tap do          |key|
        Rails.logger.warn { "[CacheKey] Generated new file key: #{key}" }
      end
    end
  end

  def gen!(*args) = uniform_key!(args)

  def memoize!(*args, &) = FAST_CACHE.getset(uniform_key!(args), &)

  def memoize_ts!(*args, &) = FAST_CACHE_TS.getset(uniform_key!(args), &)

  def uniform_key!(*args) = uniform_key(version_args!(args))

  private

  def build_mtime_values(relpath)
    return ["git@#{GIT_REVISION}"] if ENV.fetch('CACHE_KEY_IGNORE_MTIME', 'false').to_s.downcase == 'true'

    [File.mtime(relpath), File.mtime(__FILE__)]
  end

  def build_file_key(relpath)
    version = ->(path) { encode(digest.file(path).digest) }
    "#{relpath}:#{version.call(relpath)}~>#{version.call(__FILE__)}"
  end

  def digest = Digest::Blake3

  def encode(data) = Base64.urlsafe_encode64(data, padding: false)

  def marshal(args) = Oj.dump(args, mode: :object)

  def version_args!(args)
    caller_location = caller_locations.find { it.to_s.exclude?(File.basename(__FILE__)) }
    file_key = file_digest!(caller_location.absolute_path, caller_location.to_s)
    [*args].unshift(file_key, caller_location.lineno, caller_location.label)
  end

  def uniform_key(*args) = encode(digest.hexdigest(marshal(args)))
end
