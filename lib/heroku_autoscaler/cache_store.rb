require "dalli"

module HerokuAutoscaler
  class CacheStore
    TAG = "heroku-autoscale"

    def initialize
      @cache = Dalli::Client.new(ENV.fetch("MEMCACHE_SERVERS"))
    end

    def set(key, value)
      @cache.set("#{TAG}:#{key}", value)
    end

    def set_now(key)
      @cache.set("#{TAG}:#{key}", Time.now)
    end

    def fetch(key)
      @cache.fetch("#{TAG}:#{key}")
    end

    def fetch_number(key)
      fetch(key) || 0
    end

    def delete(key)
      @cache.delete("#{TAG}:#{key}")
    end
  end
end
