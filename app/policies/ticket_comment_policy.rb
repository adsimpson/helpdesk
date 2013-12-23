class TicketCommentPolicy < ApplicationPolicy
  
  def show?
    # end users can only see public comments (for tickets they have requested)
    (end_user? && !ticket.public) ? false : default_permissions
  end
  
  def create?
    default_permissions
  end
  
  def update?
    # end users cannot update comments
    end_user? ? false : default_permissions
  end

def permitted_attributes
    attrs = []
    attrs << :body if new_comment?
    attrs << :author_id if (new_comment? && !end_user?)
    attrs << :public unless user.end_user?
    attrs
  end
  
private

  def default_permissions
    if end_user?
      # end users can CRU public comments for tickets they have requested
      # TODO - shared organizations (end_users can see each other's tickets)
      user == ticket.requester
    elsif agent?
      # agents can CRU comments for all tickets unless assigned to a specific organization
      user.organization.nil? ? true : user.organization == ticket.organization
    else
      # admins can CRU comments for all tickets
      true
    end
  end
  
  def comment
    record
  end
  
  def ticket
    record.respond_to?(:ticket) ? comment.ticket : nil
  end
  
  def new_comment?
    new_record?
  end

end
