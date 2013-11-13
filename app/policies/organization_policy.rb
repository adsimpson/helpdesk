class OrganizationPolicy < ApplicationPolicy
  
  def permitted_attributes
    [:name, :external_id, :notes, :group_id, :domains => [], :tags => []]
  end

end