class Api::V1::UsersController < Api::V1::BaseController
  before_action :load_user, :except => [:index, :show_current_user, :create]

  def index
    authorize User
    render :json => User.all
  end
  
  def show
    authorize @user
    render :json => @user
  end
  
  def show_current_user
    authorize current_user
    render :json => current_user
  end  
  
  def create
    @user = User.new
    params = modify_email_params(permitted_params)
    @user.assign_attributes params
    authorize @user
 
    if @user.save
      @user.email_addresses.each do |email_address|
        EmailVerificationService.new(email_address).send_instructions unless email_address.verified
      end
      render :json => @user, :status => :created  
    else
      error!(:invalid_resource, @user.errors, "User has not been created")
    end
  end
  
  def update
    authorize @user
    params = permitted_params
    verified = params.delete :verified
    if @user.update_attributes params
      @user.email_addresses.update_all(verified: true) if verified == true
      render :json => @user, :status => :ok
    else
      error!(:invalid_resource, @user.errors, "User has not been updated")
    end
  end
  
  def destroy
    authorize @user
    @user.destroy
    render :json => {}, :status => :no_content
  end
  
private
  
  def load_user
    @user = User.find params[:id]
  end
  
  def permitted_params
    params.require(:user).permit(policy(@user).permitted_attributes)
  end
  
  def modify_email_params(params)
    emails = params.has_key?(:emails) ? Array(params[:emails]) : Array(params[:email])
    verified = !EmailVerificationService.active? || (params[:verified] == true)
      
    unless emails.empty?
      params[:email_addresses_attributes] = []
      emails.each do |email|
        email_address = {value: email}
        email_address.merge!(verified: true) if verified
        params[:email_addresses_attributes] << email_address
      end
    end
    [:email,:emails,:verified].each { |p| params.delete p }
    params
  end
  

end