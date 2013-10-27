class AddIndexesToGroupMemberships < ActiveRecord::Migration
  def change
    add_index :group_memberships, [:group_id, :user_id], unique: true
    add_index :group_memberships, [:user_id, :group_id], unique: true
  end
end
