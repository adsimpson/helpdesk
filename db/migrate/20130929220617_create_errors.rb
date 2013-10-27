class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.string :name
      t.integer :code
      t.string :http_status
      t.string :description

      t.timestamps
    end
    add_index :errors, :name, unique: true
    add_index :errors, :code, unique: true
  end
end



