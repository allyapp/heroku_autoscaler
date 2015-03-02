require "faraday"
require "heroku_autoscaler/models"

module HerokuAutoscaler
  class NewRelicMetrics
    BASE_URL          = "https://api.newrelic.com/v2/applications/#{ENV.fetch('NEW_RELIC_APP_ID')}"
    METRICS_URL       = "#{BASE_URL}/metrics.json"
    METRICS_DATA_URL  = "#{BASE_URL}/metrics/data.json"

    def initialize(options = {})
      @logging = options[:logging]
    end

    def metrics_list(page = 1)
      execute("#{METRICS_URL}?page=#{page}")
    end

    def queue_time
      execute(METRICS_DATA_URL,
              "names[]"   => "WebFrontend/QueueTime",
              "from"      => from_time,
              "to"        => to_time,
              "summarize" => true
      )
    end

    private

    def from_time
      (Time.now - 60).to_s
    end

    def to_time
      Time.now.to_s
    end

    def execute(url, params = {})
      response = request(url, params)
      parse_metrics(response)
    rescue Faraday::ClientError
      raise NewRelicError
    end

    def request(url, params)
      Faraday.get(url, params) { |req| req.headers["X-Api-Key"] = ENV.fetch("NEW_RELIC_API_KEY") }
    end

    def parse_metrics(response)
      hash_metrics = JSON.parse(response.body)["metric_data"]["metrics"].first
      metric = Metric.new(hash_metrics)
      metric.print_summary if @logging
      metric
    end
  end
end
