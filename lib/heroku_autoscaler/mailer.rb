require "mail"
require "heroku_autoscaler/template_renderer"

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
      html_part, text_part = multipart_request_queueing_alert(dynos, metrics, time, max_queue_time)
      deliver("Performance Alert: Request Queueing average exceeded", html_part, text_part)
    end

    def multipart_request_queueing_alert(dynos, metrics, time, max_queue_time)
      %w(html text).map do |type|
        Mail::Part.new do
          content_type "text/html; charset=UTF-8" if type == "html"
          body TemplateRenderer.alert(type, dynos, metrics, time, max_queue_time)
        end
      end
    end

    def deliver(subject, html_part, text_part)
      mail           = Mail::Message.new
      mail.from      = email_config[:user_name]
      mail.to        = email_config[:to]
      mail.subject   = subject
      mail.html_part = html_part
      mail.text_part = text_part
      mail.deliver
    end
  end
end
