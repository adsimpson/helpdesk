class Domain < ActiveRecord::Base
  
  # associations
  belongs_to :organization
 
  # validations
  VALID_NAME_REGEX = /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}+\z/i
  validates :name, presence: true, format: { with: VALID_NAME_REGEX }, uniqueness: { case_sensitive: false }
  
  validates_existence_of :organization, allow_nil: true
  
  # callbacks
  before_save :update_name_lower
  
private
  
  def update_name_lower 
    self.name = name.downcase
  end

end