require "virtus"
require "heroku_autoscaler/models/metric_values"

module HerokuAutoscaler
  class Timeslice
    include Virtus.model

    attribute :from,    Time
    attribute :to,      Time
    attribute :values,  MetricValues

    def to_s
      content = ""
      content += "---------------------------\n"
      content += "# From: #{from}\n"
      content += "# To:   #{to}\n"
      content += "---------------------------\n"
      content += values.to_s
    end
  end
end
