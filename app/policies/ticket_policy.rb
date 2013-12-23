class TicketPolicy < ApplicationPolicy
  
  def show?
    if end_user?
      # end users can see tickets they have requested
      # TODO - shared organizations (end_users can see each other's tickets)
      user == ticket.requester
    elsif agent?
      # agents can view all tickets unless assigned to a specific organization
      user.organization.nil? ? true : user.organization == ticket.organization
    else
      # admins can view all tickets
      true
    end
  end
  
  def create?
    # all users can create tickets
    true
  end
  
  def update?
    if end_user?
      # end users cannot update tickets
      false
    elsif agent?
      # agents can update all tickets unless assigned to a specific organization
      user.organization.nil? ? true : user.organization == ticket.organization
    else
      # admins can update all tickets
      true
    end
  end
  
  def destroy?
    # only admins can delete tickets
    admin?
  end
  
  def permitted_attributes
    attrs = ["subject", "external_id"]
    
    # attributes that CAN ONLY be specified on create
    if new_ticket?
      attrs << :description
    end
    
    # attributes that CANNOT be specified by end_users
    unless end_user?
      attrs << :ticket_type 
      attrs << :priority
      attrs << :status 
      attrs << {:tags => []}
      attrs << :requester_id
      attrs << :assignee_id
      attrs << :group_id
    end
    
    attrs
  end
  
private
  
  def ticket
    record
  end
  
  def new_ticket?
    new_record?
  end
  
end
