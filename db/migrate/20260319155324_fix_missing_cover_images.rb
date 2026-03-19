class FixMissingCoverImages < ActiveRecord::Migration[8.1]
  class MigrationGame < ApplicationRecord
    self.table_name = "games"
  end

  COVER_IMAGES = {
    "dota 2"              => "https://images.igdb.com/igdb/image/upload/t_cover_big/cobfk4.jpg",
    "baldur's gate 3"     => "https://images.igdb.com/igdb/image/upload/t_cover_big/co670h.jpg",
    "pubg: battlegrounds" => "https://images.igdb.com/igdb/image/upload/t_cover_big/coaam4.jpg",
    "battlefield 6"       => "https://images.igdb.com/igdb/image/upload/t_cover_big/coa5zt.jpg"
  }.freeze

  def up
    COVER_IMAGES.each do |name, url|
      game = MigrationGame.find_by("LOWER(name) = ?", name)
      next unless game
      game.update!(cover_image: url) if game.cover_image.blank?
    end
  end

  def down
    # No rollback — blanking cover_image would break things
  end
end
