class Api::V1::TicketSerializer < Api::V1::BaseSerializer
  serializes :Ticket
  
  # Attributes
  attributes :id, :subject, :description, :ticket_type, :status, :priority, :external_id, :tags, :created_at, :updated_at

  # Decorator attributes
  def tags
    object.tag_list
  end

end
