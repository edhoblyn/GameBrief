class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :game, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :start_date

      t.timestamps
    end
  end
end
