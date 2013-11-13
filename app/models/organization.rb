class Organization < ActiveRecord::Base
  
  # associations
  belongs_to :group
  has_many :users, dependent: :nullify
  has_many :domains, dependent: :destroy
  accepts_nested_attributes_for :domains, allow_destroy: true
 
  # validations
  validates :name, presence: true, length: {maximum: 50}, uniqueness: { case_sensitive: false }  
  validates_existence_of :group, allow_nil: true

end
