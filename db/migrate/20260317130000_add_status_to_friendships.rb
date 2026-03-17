class AddStatusToFriendships < ActiveRecord::Migration[8.1]
  def change
    add_column :friendships, :status, :string, default: "accepted", null: false
    add_index  :friendships, :status
  end
end
