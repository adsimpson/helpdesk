class RemoveTypeFromUserEmails < ActiveRecord::Migration
  def change
    remove_column :user_emails, :type
  end
end
