class AddDeletedColumnToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :deleted, :boolean, :default => false
  end
end
