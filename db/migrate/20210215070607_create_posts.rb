class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.string :img
      t.string :artist
      t.string :music
      t.string :comment
      t.timestamps null: false
    end
  end
end
