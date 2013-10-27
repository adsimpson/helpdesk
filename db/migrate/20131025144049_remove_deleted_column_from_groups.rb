class RemoveDeletedColumnFromGroups < ActiveRecord::Migration
  def change
    remove_column :groups, :deleted, :boolean, :default => false
  end
end
