class AddSummaryRequestedAtToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :summary_requested_at, :datetime
  end
end
