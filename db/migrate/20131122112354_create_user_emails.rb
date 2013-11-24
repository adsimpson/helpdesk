class CreateUserEmails < ActiveRecord::Migration
  def change
    create_table :user_emails do |t|
      t.belongs_to :user, null: false
      t.string :type, null: false
      t.string :address, null: false
      t.boolean :verified, default: false
      t.boolean :primary, default: false
      t.timestamps
    end
    add_index :user_emails, :user_id
    add_index :user_emails, :address, unique: true
    
    drop_table :user_identities
  end
end
