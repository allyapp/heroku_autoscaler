require "heroku-api"

module HerokuAutoscaler
  class Heroku
    def account
      @account ||= Heroku::API.new(api_key: ENV.fetch("HEROKU_API_KEY"))
    end

    def dynos
      @dynos ||= app.data[:body]["dynos"]
    end

    def app
      @app ||= account.get_app(ENV.fetch("HEROKU_APP_NAME"))
    end

    def scale_dynos(new_dynos)
      account.post_ps_scale(ENV.fetch("HEROKU_APP_NAME"), "web", new_dynos)
      puts "==> Scaling from #{heroku.dynos} to #{new_dynos} dynos"
    end
  end
end
