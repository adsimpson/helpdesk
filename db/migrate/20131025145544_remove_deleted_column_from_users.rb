class RemoveDeletedColumnFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :deleted, :boolean, :default => false
  end
end
