class AddSummaryToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :summary, :text
  end
end
