class CreateGameSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table :game_suggestions do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
