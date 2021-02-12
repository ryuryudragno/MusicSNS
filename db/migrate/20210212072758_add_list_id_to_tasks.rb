class AddListIdToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :list_id, :integer, default: 1 #tasksテーブルに行を加えていく
  end
end
