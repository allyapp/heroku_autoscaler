require "mail"

module HerokuAutoscaler
  class Mailer
    Mail.defaults do
      delivery_method :smtp,         address:              "smtp.gmail.com",
        host:                 "smtp.gmail.com",
        port:                 587,
        domain:               "allryder.com",
        user_name:            ENV.fetch("AUTOSCALER_EMAIL_SENDER"),
        password:             ENV.fetch("AUTOSCALER_EMAIL_PASSWORD"),
        enable_starttls_auto: true
    end

    def self.request_queueing_alert(dynos, metrics, time, max_queue_time)
      message = "The average request queueing time is over #{max_queue_time} miliseconds"
      message += "for more than #{time} seconds running with #{dynos} dynos"
      message += "According to your traffic you should probably increase the maximum number of dynos, currently set to #{dynos}\n\n\n\n"
      message += metrics.first.to_s
      deliver(message, "Performance Alert: Request Queueing average exceeded")
    end

    def self.deliver(message, subject)
      Mail.deliver do
        from ENV.fetch("AUTOSCALER_EMAIL_SENDER")
        to ENV.fetch("AUTOSCALER_EMAIL_RECEIVER")
        subject subject
        body message
      end
    end
  end
end
