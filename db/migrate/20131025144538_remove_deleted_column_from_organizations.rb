class RemoveDeletedColumnFromOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :deleted, :boolean, :default => false
  end
end
