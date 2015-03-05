require "virtus"
require "heroku_autoscaler/models/metric_values"

module HerokuAutoscaler
  class Timeslice
    include Virtus.model

    attribute :from,    Time
    attribute :to,      Time
    attribute :values,  MetricValues
  end
end
