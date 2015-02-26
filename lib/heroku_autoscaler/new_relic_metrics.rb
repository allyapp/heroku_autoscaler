require "faraday"
require "heroku_autoscaler/models"

module HerokuAutoscaler
  class NewRelicMetrics
    BASE_URL          = "https://api.newrelic.com/v2/applications/#{ENV.fetch('NEW_RELIC_APP_ID')}"
    METRICS_URL       = "#{BASE_URL}/metrics.json"
    METRICS_DATA_URL  = "#{BASE_URL}/metrics/data.json"

    def metrics_list(page = 1)
      pp execute("#{METRICS_URL}?page=#{page}", {})
    end

    def queue_time
      execute(METRICS_DATA_URL,
              "names[]"   => "WebFrontend/QueueTime",
              "from"      => (Time.now - 60).to_s,
              "to"        => Time.now.to_s,
              "summarize" => true
      )
    end

    private

    def print(metrics)
      timeslice = metrics.first.timeslices.first
      values    = timeslice.values

      puts "========================================================"
      puts "Metric: #{metrics.first.name}"
      puts "From:   #{timeslice.from}"
      puts "To:     #{timeslice.to}"
      puts "RPM:    #{values.calls_per_minute} | AverageResponse: #{values.average_response_time} | MaxResponse: #{values.max_response_time} | MinResponse: #{values.min_response_time}"
      puts "========================================================"
    end

    def execute(url, params)
      response = Faraday.get(url, params) do |req|
        req.headers["X-Api-Key"] = ENV.fetch("NEW_RELIC_API_KEY")
      end
      parse_metrics(response)
    rescue Faraday::ClientError
      raise NewRelicError
    end

    def parse_metrics(response)
      body    = JSON.parse(response.body)
      metrics = MetricData.new(body["metric_data"]).metrics
      print(metrics)
      metrics
    end
  end
end
