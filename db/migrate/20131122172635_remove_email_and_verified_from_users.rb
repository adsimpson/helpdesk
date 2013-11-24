class RemoveEmailAndVerifiedFromUsers < ActiveRecord::Migration
  def change
    remove_index :users, :email
    remove_column :users, :email
    remove_column :users, :verified
  end
end
