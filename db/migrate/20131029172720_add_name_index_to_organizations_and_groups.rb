class AddNameIndexToOrganizationsAndGroups < ActiveRecord::Migration
  def change
    add_index :organizations, :name, unique: true
    add_index :groups, :name, unique: true
  end
end
