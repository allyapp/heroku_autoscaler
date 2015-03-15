require "heroku_autoscaler/new_relic_metrics"

module HerokuAutoscaler
  class MetricsInterface
    def initialize(options)
      @options = options
    end

    def queue_time
      @queu_time ||= metrics.queue_time
    end

    def queue_average_response_time
      queue_time.values.average_response_time
    end

    def http_response_time
      @http_response_time ||= metrics.http_dispatcher
    end

    def http_average_response_time
      http_response_time.values.average_response_time
    end

    private

    def metrics
      @new_relic_metrics ||= NewRelicMetrics.new(@options)
    end
  end
end
