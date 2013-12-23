class Ticket < ActiveRecord::Base
  
  # non-persistent attributes
  attr_accessor :description
  
  # associations
  belongs_to :requester, :class_name => "User"
  belongs_to :submitter, :class_name => "User"
  belongs_to :assignee, :class_name => "User"
  belongs_to :group
  has_many :comments, :class_name => "TicketComment", dependent: :destroy
  accepts_nested_attributes_for :comments
  acts_as_taggable
 
  # validations
  validates_presence_of :description
  validates_inclusion_of :ticket_type, in: ["problem", "incident", "question", "task"], allow_nil: true
  validates_inclusion_of :status, in: ["new", "open", "pending", "hold", "solved", "closed"]
  validates_inclusion_of :priority, in: ["urgent", "high", "normal", "low"]
  validates_existence_of :requester
  validates_existence_of :submitter
  validates_existence_of :assignee, allow_nil: true
  validate :assignee_validator
  validates_existence_of :group, allow_nil: true
  
  # callbacks
  before_validation :set_submitter_to_requester, on: :create
  before_validation :set_first_comment_author_to_submitter, on: :create
  before_validation :set_group_from_assignee, on: :create
  before_save :set_tags_from_requester
  
  # proxy setting & reading of 'description' attribute to the 'body' attribute of the first comment
  def description=(description)
    first_comment.body = description
  end
  
  def description
    first_comment.body
  end
  
  def organization
    self.requester.organization unless self.requester.nil?
  end
  
private
  
  def first_comment
    self.comments.first || self.comments.build
  end
  
  def set_submitter_to_requester
    self.submitter = self.requester if self.submitter.nil?
  end

  def set_first_comment_author_to_submitter
    first_comment.author = self.submitter
  end
  
  def set_group_from_assignee
    unless (!!self.group || self.assignee.nil?)
      default_group_membership = self.assignee.group_memberships.where(default: true).first
      self.group = default_group_membership.group unless default_group_membership.nil?
    end
  end
  
  def assignee_validator
    unless self.assignee.nil?
      errors.add(:assignee, "must be an 'agent' or 'admin'") unless self.assignee.admin_or_agent?
      unless (self.group.nil? || self.assignee.groups.include?(self.group))
        errors.add(:assignee, "is not a member of the group the ticket is assigned to")
      end
    end
  end

  def set_tags_from_requester
    if (!!self.requester && self.requester_id_changed?)
      # remove tags associated with previous requester (if any)
      old_requester_id = self.requester_id_was
      old_requester = old_requester_id.nil? ? nil : User.find(old_requester_id)
      old_tags = old_requester.nil? ? [] : old_requester.full_tag_list
      self.tag_list.remove(old_tags) unless old_tags.empty?
      # add tags associated with new requester (if any)
      new_tags = self.requester.full_tag_list
      self.tag_list.add(new_tags) unless new_tags.empty?      
    end
  end
  
end