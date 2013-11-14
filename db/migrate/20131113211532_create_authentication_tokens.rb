class CreateAuthenticationTokens < ActiveRecord::Migration
  def change
    create_table :authentication_tokens do |t|
      t.string :token_digest
      t.belongs_to :user
      t.timestamps
    end
    add_index :authentication_tokens, :token_digest, unique: true
  end
end
