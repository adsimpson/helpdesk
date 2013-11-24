class PasswordResetToken < ActiveRecord::Migration
  def change
    drop_table :password_reset_tokens
    
    create_table :password_reset_tokens do |t|
      t.string :token_digest, null: false
      t.belongs_to :email_address, null: false
      t.datetime :expires_at
      t.timestamps
    end
    add_index :password_reset_tokens, :email_address_id
    add_index :password_reset_tokens, :token_digest, unique: true
  end
end
