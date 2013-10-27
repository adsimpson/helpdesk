class ChangeRoleDefaultOnUsers < ActiveRecord::Migration
  def self.up
    change_column_default(:users, :role, 'agent')
  end

  def self.down
    # You can't currently remove default values in Rails
    raise ActiveRecord::IrreversibleMigration, "Can't remove the default"
  end
end