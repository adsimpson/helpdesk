class AddDeletedColumnToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :deleted, :boolean, :default => false
  end
end
