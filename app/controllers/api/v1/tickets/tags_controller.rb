class Api::V1::Tickets::TagsController < Api::V1::BaseController
  before_action :load_ticket
  before_action :load_tag_params
  
  # returns a list of tags for the ticket
  def index
    authorize @ticket
    render :json => @ticket.tags
  end

  # sets tags for ticket (replacing any existing tags)
  def create
    authorize @ticket
    if @ticket.update_attributes(tag_list: @tags)
      render :json => @ticket.reload.tags, :status => :created
    else
      error!(:invalid_resource, @ticket.errors, "Tags have not been saved")
    end
  end

  # adds tags to ticket (appended to any existing tags)
  def update
    authorize @ticket
    @ticket.tag_list.add @tags
    if @ticket.save
      render :json => @ticket.reload.tags
    else
      error!(:invalid_resource, @ticket.errors, "Tags have not been saved")
    end
  end
  
  # remove named tags (if any), else all tags
  def destroy
    authorize @ticket
    @tags = @ticket.tag_list if @tags.empty?
    @ticket.tag_list.remove @tags
    if @ticket.save
      render :json => @ticket.reload.tags
    else
      error!(:invalid_resource, @ticket.errors, "Tags have not been saved")
    end
  end

private
  
  def load_ticket
    @ticket = Ticket.find params[:ticket_id]
  end
  
  def load_tag_params
    @tags = permitted_params[:tags]
    @tags = [] if @tags.nil?
  end
  
  def permitted_params
    params.permit([:tags => []])
  end
  
end