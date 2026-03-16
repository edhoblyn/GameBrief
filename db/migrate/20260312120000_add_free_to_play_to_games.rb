class AddFreeToPlayToGames < ActiveRecord::Migration[8.1]
  class MigrationGame < ApplicationRecord
    self.table_name = "games"
  end

  FREE_TO_PLAY_SLUGS = %w[
    fortnite
    call-of-duty-warzone
    apex-legends
    roblox
    clash-royale
    clash-of-clans
    valorant
    marvel-rivals
  ].freeze

  def up
    add_column :games, :free_to_play, :boolean, default: false, null: false

    MigrationGame.where(slug: FREE_TO_PLAY_SLUGS).update_all(free_to_play: true)
  end

  def down
    remove_column :games, :free_to_play
  end
end
