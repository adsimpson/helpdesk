class Api::V1::Users::EmailAddressesController < Api::V1::BaseController
  before_action :load_user
  before_action :load_email_address, :except => [:index, :create]  
  
  def index
    authorize EmailAddress
    render :json => @user.email_addresses
  end
  
  def show
    authorize @email_address
    render :json => @email_address
  end
  
  def create
    @email_address = @user.email_addresses.new
    @email_address.assign_attributes permitted_params
    @email_address.verified = true unless EmailVerificationService.active?
    authorize @email_address

    if @email_address.save
      EmailVerificationService.new(@email_address).send_instructions unless @email_address.verified
      render :json => @email_address, :status => :created  
    else
      error!(:invalid_resource, @email_address.errors, 'Email address has not been created')
    end
  end
  
  def update
    authorize @email_address
    
    params = permitted_params
    # only allow primary to be set to true [i.e. not false]
    params.delete(:primary) unless params[:primary] == true
    # don't allow setting primary to true unless email is verified
    if params[:primary] && !params[:verified] && !@email_address.verified
      error! :bad_request, 'Unverified email address cannot be set as primary'
    end
    
    if @email_address.update_attributes params
      render :json => @email_address, :status => :ok
    else
      error!(:invalid_resource, @email_address.errors, 'Email address has not been updated')
    end
  end
  
  def destroy 
    authorize @email_address
    @email_address.destroy
    render :json => {}, :status => :no_content
  end

  def make_primary
    authorize @email_address
    if @email_address.update_attributes :primary => true
      render :json => @email_address, :status => :ok
    else
      error!(:invalid_resource, @email_address.errors, 'Email address has not been updated')
    end
  end
  
private
  
  def load_user
    @user = User.find params[:user_id]
  end
  
  def load_email_address
    @email_address = @user.email_addresses.find params[:id]
  end
  
  def permitted_params
    params.require(:email_address).permit(policy(@email_address).permitted_attributes)
  end
end