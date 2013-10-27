class ChangeArrayColumnsToTextOnOrganizations < ActiveRecord::Migration
  def change
    remove_column :organizations, :domains, :string
    remove_column :organizations, :tags, :string
    
    add_column :organizations, :domains, :text
    add_column :organizations, :tags, :text  
  end
end
