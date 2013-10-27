class Group < ActiveRecord::Base
  
  has_many :group_memberships, :dependent => :destroy
  has_many :users, :through => :group_memberships
  
  validates :name, presence: true, length: {maximum: 50}
  
end