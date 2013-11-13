class AddGroupMappingToOrganizations < ActiveRecord::Migration
  def change
    change_table :organizations do |t|
      t.belongs_to :group
    end
  end
end
