require "heroku-api"

module HerokuAutoscaler
  class Heroku
    def initialize(cache)
      @cache    = cache
      @api_key  = ENV.fetch("HEROKU_API_KEY")
      @app_name = ENV.fetch("HEROKU_APP_NAME")
    end

    def account
      @account ||= ::Heroku::API.new(api_key: @api_key)
    end

    def dynos
      @dynos ||= app.data[:body]["dynos"]
    end

    def app
      @app ||= account.get_app(@app_name)
    end

    def scale_dynos(new_dynos)
      scaled = account.post_ps_scale(@app_name, "web", new_dynos)
      after_scale_response(scaled.body, new_dynos)
    end

    private

    def after_scale_response(new_dynos, real_scaled_dynos)
      if real_scaled_dynos == new_dynos
        puts "==> Scaling from #{dynos} to #{new_dynos} dynos"
        real_scaled_dynos
      else
        # TODO: Send an email if scaling dynos request failed more than x times
      end
    end
  end
end
