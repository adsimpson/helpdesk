class CreateEmailVerificationTokens < ActiveRecord::Migration
  def change
    create_table :email_verification_tokens do |t|
      t.string :token_digest, null: false
      t.belongs_to :user, null: false
      t.datetime :expires_at
      t.timestamps
    end
    add_index :email_verification_tokens, :user_id, unique: false
    add_index :email_verification_tokens, :token_digest, unique: true

    remove_index :users, :verification_token
    remove_column :users, :verification_token, :string
    remove_column :users, :verification_token_expires_at, :datetime
  end
end
