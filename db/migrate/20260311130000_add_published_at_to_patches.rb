class AddPublishedAtToPatches < ActiveRecord::Migration[8.1]
  def up
    add_column :patches, :published_at, :datetime
    add_index :patches, :published_at

    execute <<~SQL.squish
      UPDATE patches
      SET published_at = created_at
      WHERE published_at IS NULL
    SQL
  end

  def down
    remove_index :patches, :published_at
    remove_column :patches, :published_at
  end
end
