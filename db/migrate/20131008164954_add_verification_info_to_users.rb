class AddVerificationInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :verified_at, :datetime
    add_column :users, :verification_token, :string
    add_column :users, :verification_token_expires_at, :datetime
    
    add_index :users, :verification_token, unique: true
  end
end
