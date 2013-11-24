class ChangeUserEmailAddresses < ActiveRecord::Migration
  def change
    create_table :email_addresses do |t|
      t.belongs_to :user, null: false
      t.string :value, null: false
      t.boolean :verified, default: false
      t.boolean :primary, default: false
      t.timestamps
    end
    add_index :email_addresses, :user_id
    add_index :email_addresses, :value, unique: true
    
    drop_table :user_email_addresses
  end
end
