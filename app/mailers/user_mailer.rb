class UserMailer < ActionMailer::Base
 
  def password_reset_instructions(user, config)
    @user, @config = user, config
    @url  = "#{@config[:base_url]}?token=#{@user.password_reset_token}"
    mail(from: build_from_address, to: @user.email, subject: @config[:subject]) 
  end

  def password_reset_success(user,config)
    @user, @config = user, config
    mail(from: build_from_address, to: @user.email, subject: @config[:subject])
  end

  def email_verification_instructions(user, config)
    @user, @config = user, config
    @url  = "#{@config[:base_url]}?token=#{@user.verification_token}"
    mail(from: build_from_address, to: @user.email, subject: @config[:subject]) 
  end

  def email_verification_success(user,config)
    @user, @config = user, config
    mail(from: build_from_address, to: @user.email, subject: @config[:subject])
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