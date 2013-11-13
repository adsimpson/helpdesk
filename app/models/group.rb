class Group < ActiveRecord::Base
  
  # associations
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
 
  # validations
  validates :name, presence: true, length: {maximum: 50}, uniqueness: { case_sensitive: false } 
  
end