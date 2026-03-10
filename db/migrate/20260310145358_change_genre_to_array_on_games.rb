class ChangeGenreToArrayOnGames < ActiveRecord::Migration[8.1]
  def change
    remove_column :games, :genre
    add_column :games, :genre, :string, array: true, default: []
  end
end
