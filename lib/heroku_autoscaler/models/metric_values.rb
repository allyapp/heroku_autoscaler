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

    def to_s
      content = ""
      content += "* Average response time:      #{average_response_time}\n"
      content += "* Calls per minute:           #{calls_per_minute}\n"
      content += "* Call count:                 #{call_count}\n"
      content += "* Average value:              #{average_value}\n"
      content += "* Min response time:          #{min_response_time}\n"
      content += "* Max response time:          #{max_response_time}\n"
      content += "* Average exclusive Time:     #{average_exclusive_time}\n"
      content += "* Total call time per minute: #{total_call_time_per_minute}\n"
      content += "* Requests per minute:        #{requests_per_minute}\n"
      content += "* Standard Deviation:         #{standard_deviation}\n"
      content
    end
  end
end
