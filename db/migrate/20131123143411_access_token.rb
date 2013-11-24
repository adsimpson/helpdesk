class AccessToken < ActiveRecord::Migration
  def change
    drop_table :access_tokens
    
    create_table :access_tokens do |t|
      t.string :token_digest, null: false
      t.belongs_to :email_address, null: false
      t.boolean  :active, default: true, null: false
      t.datetime :expires_at
      t.timestamps
    end
    add_index :access_tokens, :email_address_id
    add_index :access_tokens, :token_digest, unique: true
  end
end
