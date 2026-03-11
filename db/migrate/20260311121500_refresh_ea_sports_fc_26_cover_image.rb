class RefreshEaSportsFc26CoverImage < ActiveRecord::Migration[8.1]
  class MigrationGame < ApplicationRecord
    self.table_name = "games"
  end

  FC26_COVER_IMAGE = "https://images.igdb.com/igdb/image/upload/t_cover_big/coa5wx.jpg"

  def up
    game = MigrationGame.find_by("LOWER(name) = ?", "ea sports fc 26")
    return unless game

    game.update!(cover_image: FC26_COVER_IMAGE, slug: "ea-sports-fc-26")
  end

  def down
    game = MigrationGame.find_by("LOWER(name) = ?", "ea sports fc 26")
    return unless game

    game.update!(cover_image: "https://images.igdb.com/igdb/image/upload/t_cover_big/co6qqa.jpg")
  end
end
