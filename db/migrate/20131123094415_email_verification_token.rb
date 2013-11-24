class EmailVerificationToken < ActiveRecord::Migration
  def change
    drop_table :email_verification_tokens
    
    create_table :email_verification_tokens do |t|
      t.string :token_digest, null: false
      t.belongs_to :email_address, null: false
      t.datetime :expires_at
      t.timestamps
    end
    add_index :email_verification_tokens, :email_address_id
    add_index :email_verification_tokens, :token_digest, unique: true

  end
end
