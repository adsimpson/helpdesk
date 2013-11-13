class RemoveDomainsAndTagsFromOrganization < ActiveRecord::Migration
  def change
    remove_column :organizations, :domains, :string
    remove_column :organizations, :tags, :string
  end
end
