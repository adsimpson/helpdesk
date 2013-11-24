class AddUserIndexToUserIdentities < ActiveRecord::Migration
  def change
    add_index :user_identities, :user_id, unique: false
  end
end
