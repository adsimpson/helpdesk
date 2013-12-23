class TicketComment < ActiveRecord::Base
  
  # the following attributes can (must) be set on create, but will be ignored on updates
  attr_readonly :body, :ticket_id, :author_id
  
  # associations
  belongs_to :ticket
  belongs_to :author, :class_name => "User"

  # validations
  validates_existence_of :ticket, allow_nil: true
  validates_existence_of :author
  validates_presence_of :body

end