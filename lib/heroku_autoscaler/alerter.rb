module HerokuAutoscaler
  class Alerter
    ALERT_FREQUENCY       = 60 # sec
    EXEC_FREQUENCY        = 15 # sec
    FAILED_UPSCALES_ALERT = 4 # Min count of failed upscales to send an alert
    EVENTS                = %w(failed-upscale)
    SETTINGS = %w(alert_frequency exec_frequency failed_upscales_alert)

    attr_accessor :alert_frequency, :exec_frequency, :failed_upscales_alert

    def initialize(cache, options = {})
      @cache = cache
      SETTINGS.each { |setting| send("#{setting}=", setting_value(options, setting)) }
    end

    def restart_event_counters
      EVENTS.each { |event| cache.set(event, 0) }
    end

    # If it tries to scale up, but the number of MAX_DYNOS restricts it
    def failed_upscale_alert(dynos, metrics, freq_upscale, upscale_queue_time)
      failed_upscales = failed_tries("failed-upscale", freq_upscale)
      return unless failed_upscales >= FAILED_UPSCALES_ALERT

      proc = proc { Mailer.request_queueing_alert(dynos, metrics, failed_upscales * freq_upscale, upscale_queue_time) }
      send_alert("failed-upscale", proc)
    end

    private

    attr_reader :cache

    def setting_value(options, setting)
      options[setting.to_sym] || env_value(setting) || Object.const_get("#{self.class}::#{setting.upcase}")
    end

    def env_value(setting)
      ENV[setting.upcase] && Integer(ENV[setting.upcase])
    end

    def failed_tries(failed_event, freq_upscale)
      failed_event_times = cache.fetch_number(failed_event)
      failed_event_times += EXEC_FREQUENCY.to_f / freq_upscale.to_f
      cache.set(failed_event, failed_event_times)
      failed_event_times
    end

    def send_alert(alert_name, proc)
      last_alert_sent = cache.fetch("alert-sent:#{alert_name}")
      return unless !last_alert_sent || Time.now - last_alert_sent >= ALERT_FREQUENCY

      proc.call
      cache.set_now("alert-sent:#{alert_name}")
    end
  end
end
