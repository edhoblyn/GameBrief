class CreatePatchSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :patch_summaries do |t|
      t.references :patch, null: false, foreign_key: true
      t.text :summary

      t.timestamps
    end
  end
end
