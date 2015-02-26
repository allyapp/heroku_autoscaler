require "virtus"
require "heroku_autoscaler/models/timeslice"

module HerokuAutoscaler
  class Metric
    include Virtus.model

    attribute :name, String
    attribute :timeslices, Array[Timeslice]

    def to_s
      content = ""
      content += "===========================\n"
      content += "# Metric: #{name}\n"
      timeslices.each { |timeslice| content += timeslice.to_s }
      content += "===========================\n"
    end
  end
end
