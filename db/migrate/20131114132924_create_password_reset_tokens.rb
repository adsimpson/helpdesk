class CreatePasswordResetTokens < ActiveRecord::Migration
  def change
    create_table :password_reset_tokens do |t|
      t.string :token_digest, null: false
      t.belongs_to :user, null: false
      t.datetime :expires_at
      t.timestamps
    end
    add_index :password_reset_tokens, :user_id, unique: false
    add_index :password_reset_tokens, :token_digest, unique: true

    remove_index :users, :password_reset_token
    remove_column :users, :password_reset_token, :string
    remove_column :users, :password_reset_token_expires_at, :datetime
  end
end
