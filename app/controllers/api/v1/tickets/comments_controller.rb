class Api::V1::Tickets::CommentsController < Api::V1::BaseController
  before_action :load_ticket
  before_action :load_comment, :except => [:index, :create]  
  
  # returns a list of comments for the ticket
  def index
    authorize TicketComment
    # TODO - this needs be scoped by user
    render :json => @ticket.comments
  end
  
  def show
    authorize @comment
    render :json => @comment
  end

  def create
    @comment = @ticket.comments.new
    @comment.assign_attributes permitted_params
    @comment.author = current_user if @comment.author.nil?
    authorize @comment

    if @comment.save
      # TODO - run ticket through create/update triggers
      # TODO - create ticket audit records
      render :json => @comment, :status => :created  
    else
      error!(:invalid_resource, @comment.errors, 'Comment has not been created')
    end
  end
  
  def update
    authorize @comment
    
    if @comment.update_attributes permitted_params
      # TODO - run ticket through create/update triggers
      # TODO - create ticket audit records
      render :json => @comment, :status => :ok
    else
      error!(:invalid_resource, @comment.errors, 'Comment has not been updated')
    end
  end

  private
  
  def load_ticket
    @ticket = Ticket.find params[:ticket_id]
  end
  
  def load_comment
    @comment = @ticket.comments.find params[:id]
  end

  def permitted_params
    params.require(:comment).permit(policy(@comment).permitted_attributes)
  end

end