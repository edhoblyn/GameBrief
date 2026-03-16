class ReplacesFollowsWithFriendships < ActiveRecord::Migration[8.1]
  def change
    drop_table :follows do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followed, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    create_table :friendships do |t|
      t.references :user,   null: false, foreign_key: { to_table: :users }
      t.references :friend, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :friendships, [:user_id, :friend_id], unique: true
  end
end
