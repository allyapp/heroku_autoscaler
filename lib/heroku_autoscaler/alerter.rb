require "heroku_autoscaler/setter"

module HerokuAutoscaler
  class Alerter
    include Setter

    ALERT_FREQUENCY       = 60 # sec
    EXEC_FREQUENCY        = 15 # sec
    FAILED_UPSCALES_ALERT = 4 # Min count of failed upscales to send an alert
    EVENTS                = %w(failed-upscale)

    attr_accessor :alert_frequency, :exec_frequency, :failed_upscales_alert

    def initialize(cache, mailer, options = {})
      @cache  = cache
      @mailer = mailer
      writers_setting(options)
    end

    def restart_event_counters
      EVENTS.each { |event| cache.set(event, 0) }
    end

    # If it tries to scale up, but the number of MAX_DYNOS restricts it
    def failed_upscale_alert(dynos, metrics, freq_upscale, upscale_queue_time)
      failed_upscales = failed_tries("failed-upscale", freq_upscale)
      return if !@mailer || failed_upscales < failed_upscales_alert

      proc = proc { mailer.request_queueing_alert(dynos, metrics, failed_upscales * freq_upscale, upscale_queue_time) }
      send_alert("failed-upscale", proc)
    end

    private

    attr_reader :cache, :mailer

    def failed_tries(failed_event, freq_upscale)
      failed_event_times = cache.fetch_number(failed_event)
      failed_event_times += exec_frequency.to_f / freq_upscale.to_f
      cache.set(failed_event, failed_event_times)
      failed_event_times
    end

    def send_alert(alert_name, proc)
      last_alert_sent = cache.fetch("alert-sent:#{alert_name}")
      return unless !last_alert_sent || Time.now - last_alert_sent >= alert_frequency

      proc.call
      cache.set_now("alert-sent:#{alert_name}")
    end
  end
end
