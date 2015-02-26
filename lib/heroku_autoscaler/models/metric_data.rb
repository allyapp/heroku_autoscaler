require "virtus"
require "heroku_autoscaler/models/metric"

module HerokuAutoscaler
  class MetricData
    include Virtus.model

    attribute :from,    Time
    attribute :to,      Time
    attribute :metrics, Array[Metric]

    def to_s
      content = ""
      content += "############################\n"
      content += "* From: #{from}\n"
      content += "* To:   #{to}\n"
      metrics.each { |metric| content += metric.print }
      content += "############################\n"
    end
  end
end
