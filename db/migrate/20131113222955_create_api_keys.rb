class CreateApiKeys < ActiveRecord::Migration
  def change
    drop_table :authentication_tokens

    create_table :api_keys do |t|
      t.string :authentication_token, null: false
      t.belongs_to :user, null: false
      t.boolean :active, null: false, default: true
      t.datetime :expires_at
      t.timestamps
    end
    add_index :api_keys, :user_id, unique: false
    add_index :api_keys, :authentication_token, unique: true
  end
end
