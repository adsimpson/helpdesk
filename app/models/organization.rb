class Organization < ActiveRecord::Base
  
  has_many :users, :dependent => :nullify
  
  validates :name, presence: true, length: {maximum: 50}
  
  serialize :domains, Array
  serialize :tags, Array

end
