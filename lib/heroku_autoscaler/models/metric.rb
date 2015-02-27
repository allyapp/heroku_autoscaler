require "virtus"
require "heroku_autoscaler/models/timeslice"
require "forwardable"

module HerokuAutoscaler
  class Metric
    include Virtus.model
    extend Forwardable
    delegate %i(from to values) => :timeslice

    attribute :name, String
    attribute :timeslice, Timeslice

    def initialize(metric)
      @timeslice = Timeslice.new(metric["timeslices"].first)
      @name      = metric["name"]
    end

    def print_summary
      puts "========================================================"
      puts "Metric: #{name}"
      puts "From:   #{from}"
      puts "To:     #{to}"
      puts "RPM:    #{values.calls_per_minute} | AverageResponse: #{values.average_response_time} | MaxResponse: #{values.max_response_time} | MinResponse: #{values.min_response_time}"
      puts "========================================================"
    end

    def to_s
      content = ""
      content += "===========================\n"
      content += "# Metric: #{name}\n"
      timeslices.each { |timeslice| content += timeslice.to_s }
      content += "===========================\n"
    end
  end
end
