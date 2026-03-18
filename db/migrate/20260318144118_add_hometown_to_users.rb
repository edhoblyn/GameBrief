class AddHometownToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :hometown, :string
  end
end
