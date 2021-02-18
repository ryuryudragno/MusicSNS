class CreateLikes < ActiveRecord::Migration[5.2]
  def change
    create_table :likes do |t|
      t.integer :user_id #お気に入りするユーザー
      t.integer :post_id#お気に入りされた投稿
      t.timestamps null: false
    end
  end
end
