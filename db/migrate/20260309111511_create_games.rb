class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :name
      t.string :slug
      t.string :cover_image

      t.timestamps
    end
  end
end
