module HerokuAutoscaler
  class Error < StandardError; end
  class NewRelicError < Error; end
  class HerokuAuthError < Error; end
  class HerokuAppError < Error; end
  class MailerError < Error; end
end
