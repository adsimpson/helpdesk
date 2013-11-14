class ChangeTokenOnApiKeys < ActiveRecord::Migration
  def change
    remove_index :api_keys, :authentication_token
    remove_column :api_keys, :authentication_token, :string
    
    add_column :api_keys, :token_digest, :string
    add_index :api_keys, :token_digest, unique: true
  end
end
