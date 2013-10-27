class RecreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :external_id
      t.string :notes
      t.string :domains
      t.string :tags

      t.timestamps
    end
  end
end
