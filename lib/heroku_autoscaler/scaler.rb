require "heroku_autoscaler/mailer"
require "heroku_autoscaler/alerter"
require "heroku_autoscaler/cache_store"
require "heroku_autoscaler/heroku"
require "heroku_autoscaler/new_relic_metrics"

module HerokuAutoscaler
  class Scaler
    attr_accessor :freq_upscale, :freq_downscale, :min_dynos, :max_dynos, :upscale_queue_time, :downscale_queue_time

    FREQ_UPSCALE         = 30 # seconds
    FREQ_DOWNSCALE       = 60 # seconds
    MIN_DYNOS            = 1
    MAX_DYNOS            = 2
    UPSCALE_QUEUE_TIME   = 100 # ms
    DOWNSCALE_QUEUE_TIME = 30 # ms
    SETTINGS             = %w(freq_upscale freq_downscale min_dynos max_dynos upscale_queue_time downscale_queue_time)

    def initialize(options = {})
      SETTINGS.each { |setting| send("#{setting}=", setting_value(options, setting)) }
    end

    def autoscale
      puts "Dynos: #{heroku.dynos}"
      scale(heroku.dynos + 1) if upscale?
      scale(heroku.dynos - 1) if downscale?
    end

    private

    def setting_value(options, setting)
      options[setting.to_sym] || env_value(setting) || Object.const_get("#{self.class}::#{setting.upcase}")
    end

    def env_value(setting)
      ENV[setting.upcase] && Integer(ENV[setting.upcase])
    end

    def average_response_time
      @average_response_time ||= queue_time.first.timeslices.first.values.average_response_time
    end

    def queue_time
      @metrics ||= metrics.queue_time
    end

    def scale(new_dynos)
      heroku.scale_dynos(new_dynos)
      alerter.restart_event_counters
      cache.set_now("last-scale")
    end

    def upscale?
      return false unless average_response_time > upscale_queue_time && time_to_scale?(freq_upscale)
      if heroku.dynos < max_dynos
        true
      else
        alerter.failed_upscale_alert(heroku.dynos, queue_time, freq_upscale, upscale_queue_time)
        false
      end
    end

    def downscale?
      average_response_time < downscale_queue_time && time_to_scale?(freq_downscale) && heroku.dynos > min_dynos
    end

    def time_to_scale?(frequency)
      last_autoscale = cache.fetch("last-scale")
      !last_autoscale || Time.now - last_autoscale > frequency
    end

    def alerter
      @alerter ||= Alerter.new(cache)
    end

    def cache
      @cache ||= CacheStore.new
    end

    def metrics
      @new_relic_metrics ||= NewRelicMetrics.new
    end

    def heroku
      @heroku ||= Heroku.new
    end
  end
end
