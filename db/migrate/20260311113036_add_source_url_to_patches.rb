class AddSourceUrlToPatches < ActiveRecord::Migration[8.1]
  def change
    add_column :patches, :source_url, :string
  end
end
