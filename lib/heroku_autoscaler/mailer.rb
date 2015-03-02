require "mail"

module HerokuAutoscaler
  class Mailer

    attr_reader :email_config

    def initialize(email_config)
      @email_config = email_config
    end

    def config!
      Mail::Configuration.instance.delivery_method(
        email_config.fetch(:delivery_method),
        address:              email_config.fetch(:address),
        port:                 email_config.fetch(:port),
        domain:               email_config.fetch(:domain),
        user_name:            email_config.fetch(:user_name),
        password:             email_config.fetch(:password),
        enable_starttls_auto: email_config[:enable_starttls_auto] || true
      )
    end

    def request_queueing_alert(dynos, metrics, time, max_queue_time)
      message = "The average request queueing time is over #{max_queue_time} miliseconds"
      message += "for more than #{time} seconds running with #{dynos} dynos"
      message += "According to your traffic you should probably increase the maximum number of dynos, currently set to #{dynos}\n\n\n\n"
      message += metrics.to_s
      deliver("Performance Alert: Request Queueing average exceeded", message)
    end

    def deliver(subject, message)
      mail         = Mail::Message.new
      mail.from    = email_config[:user_name]
      mail.to      = email_config[:to]
      mail.body    = message
      mail.subject = subject
      mail.deliver
    end
  end
end
