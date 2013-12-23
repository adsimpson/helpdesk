class Api::V1::TicketsController < Api::V1::BaseController
  before_action :load_ticket, :except => [:index, :create]
  
  def index
    authorize Ticket
    # TODO - this needs be scoped by user
    render :json => Ticket.all
  end
  
  def show
    authorize @ticket
    render :json => @ticket
  end

  def create
    @ticket = Ticket.new
    @ticket.assign_attributes permitted_params
    @ticket.submitter = current_user
    @ticket.requester = current_user if @ticket.requester.nil?
    authorize @ticket
 
    if @ticket.save
      # TODO - run ticket through create/update triggers
      # TODO - create ticket audit records
      render :json => @ticket, :status => :created  
    else
      error!(:invalid_resource, @ticket.errors, "Ticket has not been created")
    end
  end
  
  def update
    authorize @ticket
    if @ticket.update_attributes permitted_params
      # TODO - run ticket through create/update triggers
      # TODO - create ticket audit records
      render :json => @ticket, :status => :ok
    else
      error!(:invalid_resource, @ticket.errors, "Ticket has not been updated")
    end
  end

  def destroy
    authorize @ticket
    @ticket.destroy
    render :json => {}, :status => :no_content
  end

private
  
  def load_ticket
    @ticket = Ticket.find params[:id]
  end
  
  def permitted_params
    params.require(:ticket).permit(policy(@ticket).permitted_attributes)
  end  
  
end