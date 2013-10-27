class CreateGroupMemberships < ActiveRecord::Migration
  def change
    create_table :group_memberships do |t|
      t.belongs_to :group
      t.belongs_to :user
      t.boolean :default, :default => false
      t.timestamps
    end
  end
end
