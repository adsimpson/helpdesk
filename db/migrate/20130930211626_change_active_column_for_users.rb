class ChangeActiveColumnForUsers < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, :default => true

    remove_column :users, :active?, :boolean, :default => true
  end
end
