class CreateUserIdentities < ActiveRecord::Migration
  def change
    create_table :user_identities do |t|
      t.belongs_to :user, null: false
      t.string :type, null: false
      t.string :value, null: false
      t.boolean :verified, default: false
      t.boolean :primary, default: false
      t.timestamps
    end
    add_index :user_identities, [:type, :value], unique: true
  end
end
