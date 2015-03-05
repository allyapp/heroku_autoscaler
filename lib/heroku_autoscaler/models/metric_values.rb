require "virtus"

module HerokuAutoscaler
  class MetricValues
    include Virtus.model

    attribute :average_response_time,      Float
    attribute :calls_per_minute,           Float
    attribute :call_count,                 Integer
    attribute :average_value,              Float
    attribute :min_response_time,          Float
    attribute :max_response_time,          Float
    attribute :average_exclusive_time,     Float
    attribute :total_call_time_per_minute, Float
    attribute :requests_per_minute,        Float
    attribute :standard_deviation,         Float
  end
end
