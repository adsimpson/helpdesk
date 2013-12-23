class Api::V1::TicketCommentSerializer < Api::V1::BaseSerializer
  serializes :TicketComment
  
  # Set root node to 'comment(s)'
  configure :root, :instance => :comment, :collection => :comments
  
  # Attributes
  attributes :id, :ticket_id, :author_id, :body, :public, :created_at, :updated_at

end
