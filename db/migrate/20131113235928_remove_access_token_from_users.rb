class RemoveAccessTokenFromUsers < ActiveRecord::Migration
  def change
    remove_index :users, :access_token
    remove_column :users, :access_token, :string
  end
end
