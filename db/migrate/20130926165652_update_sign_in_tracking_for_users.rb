class UpdateSignInTrackingForUsers < ActiveRecord::Migration
  def change
    add_column :users, :previous_sign_in_at, :datetime
    add_column :users, :latest_sign_in_at, :datetime

    remove_column :users, :last_sign_in_at, :datetime
    remove_column :users, :current_sign_in_at, :datetime
  end
end
