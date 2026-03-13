class AddPlayerModesToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :single_player, :boolean, default: false, null: false
    add_column :games, :multiplayer, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE games
          SET single_player = TRUE
          WHERE LOWER(name) IN (
            'destiny 2',
            'ea sports fc 26',
            'roblox',
            'minecraft',
            'resident evil requiem',
            'pokémon pokopia',
            'star wars battlefront ii',
            'horizon forbidden west',
            'final fantasy vii rebirth',
            'marvel''s spider-man 2',
            'grand theft auto v',
            'cyberpunk 2077',
            'warhammer 40,000: space marine 2',
            'genshin impact',
            'baldur''s gate 3',
            'battlefield 6'
          )
        SQL

        execute <<~SQL
          UPDATE games
          SET multiplayer = TRUE
          WHERE LOWER(name) IN (
            'fortnite',
            'call of duty: warzone',
            'apex legends',
            'destiny 2',
            'ea sports fc 26',
            'roblox',
            'clash royale',
            'clash of clans',
            'minecraft',
            'valorant',
            'marvel rivals',
            'helldivers 2',
            'overwatch 2',
            'star wars battlefront ii',
            'grand theft auto v',
            'league of legends',
            'warhammer 40,000: space marine 2',
            '2xko',
            'genshin impact',
            'counter-strike 2',
            'dota 2',
            'baldur''s gate 3',
            'pubg: battlegrounds',
            'battlefield 6'
          )
        SQL
      end
    end
  end
end
