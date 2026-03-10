class AddSummaryTypeToPatchSummaries < ActiveRecord::Migration[8.1]
  def change
    add_column :patch_summaries, :summary_type, :string
  end
end
