class CreateExceptionClasses < ActiveRecord::Migration
  def change
    create_table :exception_classes do |t|
      t.string :class_name
      t.integer :code
      t.string :http_status
      t.string :description

      t.timestamps
    end
    add_index :exception_classes, :class_name, unique: true
    add_index :exception_classes, :code, unique: true
  end
end
