class AddUserOrganizationLinks < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.belongs_to :organization
      t.change_default :role, 'end_user'
    end
  end
end
