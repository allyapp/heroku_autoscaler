require "erb"

module HerokuAutoscaler
  module TemplateRenderer
    module_function

    def alert(type, dynos, metrics, time, max_queue_time)
      render("#{type}_alert", alert_hash(dynos, metrics, time, max_queue_time))
    end

    private

    def self.alert_hash(dynos, metrics, time, max_queue_time)
      {
        max_queue_time: max_queue_time,
        time:           Integer(time),
        dynos:          dynos,
        metric:         metrics
      }
    end

    def self.render(template, hash)
      object = OpenStruct.new(hash)
      ERB.new(File.read("#{File.dirname(__FILE__)}/views/#{template}.erb")).result(object.instance_eval { binding })
    end
  end
end
