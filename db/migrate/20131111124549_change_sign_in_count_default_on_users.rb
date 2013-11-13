class ChangeSignInCountDefaultOnUsers < ActiveRecord::Migration
  def self.up
    change_column_default(:users, :sign_in_count, 0)
  end

  def self.down
    # You can't currently remove default values in Rails
    raise ActiveRecord::IrreversibleMigration, "Can't remove the default"
  end
end
