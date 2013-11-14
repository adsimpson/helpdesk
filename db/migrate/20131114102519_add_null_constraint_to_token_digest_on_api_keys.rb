class AddNullConstraintToTokenDigestOnApiKeys < ActiveRecord::Migration
  def change
    change_column :api_keys, :token_digest, :string, { null: false }
  end
end
