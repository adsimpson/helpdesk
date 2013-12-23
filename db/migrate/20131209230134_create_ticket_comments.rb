class CreateTicketComments < ActiveRecord::Migration
  def change
    create_table :ticket_comments do |t|
      t.belongs_to :ticket, null: false
      t.integer :author_id, null: false
      t.string :body, null: false
      t.boolean :public, default: true
      
      t.timestamps    
    end
    add_index :ticket_comments, :ticket_id
    add_index :ticket_comments, :author_id
  end
end
