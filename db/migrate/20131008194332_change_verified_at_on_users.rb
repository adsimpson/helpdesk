class ChangeVerifiedAtOnUsers < ActiveRecord::Migration
  def change
    add_column :users, :verified?, :boolean, :default => false
    
    remove_column :users, :verified_at, :datetime
  end
end
