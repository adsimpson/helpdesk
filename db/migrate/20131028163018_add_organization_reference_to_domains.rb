class AddOrganizationReferenceToDomains < ActiveRecord::Migration
  def change
    change_table :domains do |t|
      t.belongs_to :organization
    end
  end
end
