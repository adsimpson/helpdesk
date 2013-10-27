class AddAccessTokenIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :access_token, unique: true
  end
end
