class DevelopmentMailInterceptor

  def self.delivering_email(message)
    message.to = ENV["EMAIL_INTERCEPT"]
  end

end