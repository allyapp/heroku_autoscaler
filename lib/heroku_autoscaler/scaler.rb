require "heroku_autoscaler/alerter"
require "heroku_autoscaler/cache_store"
require "heroku_autoscaler/heroku"
require "heroku_autoscaler/metrics_interface"
require "heroku_autoscaler/setter"

module HerokuAutoscaler
  class Scaler
    include Setter

    attr_accessor :freq_upscale, :freq_downscale, :min_dynos, :max_dynos,
                  :upscale_queue_time, :downscale_queue_time

    FREQ_UPSCALE                 = 30 # seconds
    FREQ_DOWNSCALE               = 60 # seconds
    MIN_DYNOS                    = 1
    MAX_DYNOS                    = 2
    UPSCALE_QUEUE_TIME           = 100 # ms
    DOWNSCALE_QUEUE_TIME         = 30 # ms
    UPSCALE_HTTP_RESPONSE_TIME   = 3000 # ms
    DOWNSCALE_HTTP_RESPONSE_TIME = 100 # ms
    HTTP_RESPONSE_TIME_ENABLED   = false

    def initialize(options = {})
      @options = options
      writers_setting(options)
    end

    def autoscale
      puts "Dynos: #{heroku.dynos}"
      return scale(heroku.dynos + 1) if upscale?
      return scale(heroku.dynos - 1) if downscale?
    end

    private

    def scale(new_dynos)
      scaled_dynos = heroku.scale_dynos(new_dynos)
      if scaled_dynos == new_dynos
        alerter.restart_event_counters
        cache.set_now("last-scale")
      end
      scaled_dynos
    end

    def upscale?
      return false unless metrics.queue_average_response_time > upscale_queue_time && time_to_scale?(freq_upscale)
      if heroku.dynos < max_dynos
        true
      else
        alerter.failed_upscale_alert(heroku.dynos, metrics.queue_time, freq_upscale, upscale_queue_time)
        false
      end
    end

    def downscale?
      metrics.queue_average_response_time < downscale_queue_time &&
        time_to_scale?(freq_downscale) &&
        heroku.dynos > min_dynos
    end

    def time_to_scale?(frequency)
      last_autoscale = cache.fetch("last-scale")
      !last_autoscale || now - last_autoscale > frequency
    end

    def alerter
      @alerter ||= Alerter.new(cache, @options)
    end

    def cache
      @cache ||= CacheStore.new
    end

    def metrics
      @metrics ||= MetricsInterface.new(@options)
    end

    def heroku
      @heroku ||= Heroku.new(cache)
    end

    def now
      @now ||= Time.now
    end
  end
end
