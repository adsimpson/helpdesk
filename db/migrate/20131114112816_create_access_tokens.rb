class CreateAccessTokens < ActiveRecord::Migration
  def change
    drop_table :api_keys
    
    create_table :access_tokens do |t|
      t.string :token_digest, null: false
      t.belongs_to :user, null: false
      t.boolean :active, null: false, default: true
      t.datetime :expires_at
      t.timestamps
    end
    add_index :access_tokens, :user_id, unique: false
    add_index :access_tokens, :token_digest, unique: true
  end
end
