class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
    end
    add_index :domains, :name, unique: true
  end
end
