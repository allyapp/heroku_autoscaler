module HerokuAutoscaler
  module Setter
    module_function

    def writers_setting(options)
      writers_methods.each { |writer| send("#{writer}=", value_setting(options, writer)) }
    end

    private

    def writers_methods
      self.methods.grep(/\w=/) { |m| m.to_s.match(/^(\w+)=/)[1] }
    end

    def value_setting(options, setting)
      options[setting.to_sym] || env_value(setting) || Object.const_get("#{self.class}::#{setting.upcase}")
    end

    def env_value(setting)
      value = ENV[setting.upcase]
      value &&
        ( is_number?(value) && Integer(value) ||
          !is_number?(value) && ENV[setting.upcase] )
    end

    def is_number?(value)
      !!(value.match(/^(\d+)$/))
    end
  end
end
