class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :type
      t.string :status, default: "new"
      t.string :priority, default: "normal"
      t.string :subject
      t.string :external_id

      t.integer :requester_id
      t.integer :submitter_id
      t.integer :assignee_id
      t.integer :group_id

      t.timestamps
    end
    add_index :tickets, :requester_id
    add_index :tickets, :submitter_id
    add_index :tickets, :assignee_id
    add_index :tickets, :group_id
  end
end
