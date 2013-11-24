class UserMailer < ActionMailer::Base
 
  def password_reset_instructions(email_address, token, config)
    @email_address, @user, @token, @config = email_address, email_address.user, token, config
    @url  = "#{@config[:base_url]}?token=#{@token.token}"
    mail(from: build_from_address, to: @email_address.value, subject: @config[:subject]) 
  end

  def password_reset_success(email_address,config)
    @email_address, @user, @config = email_address, email_address.user, config
    mail(from: build_from_address, to: @email_address.value, subject: @config[:subject])
  end

  def email_verification_instructions(email_address, token, config)
    @email_address, @user, @token, @config = email_address, email_address.user, token, config
    @url  = "#{@config[:base_url]}?token=#{@token.token}"
    mail(from: build_from_address, to: @email_address.value, subject: @config[:subject]) 
  end

  def email_verification_success(email_address,config)
    @email_address, @user, @config = email_address, email_address.user, config
    mail(from: build_from_address, to: @email_address.value, subject: @config[:subject])
  end

private

  def build_from_address
    if @config[:from_name].blank?
      @config[:from_email]
    else
      "#{@config[:from_name]} <#{@config[:from_email]}>"
    end
  end

end