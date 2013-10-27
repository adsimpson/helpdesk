class ChangePasswordResetExpiresAtOnUser < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_token_expires_at, :datetime

    remove_column :users, :password_reset_expires_at, :datetime
  end
end
