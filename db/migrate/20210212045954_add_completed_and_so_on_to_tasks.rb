class AddCompletedAndSoOnToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :completed, :boolean #tasksテーブルに行を加えていく
    add_column :tasks, :due_date, :date
    add_column :tasks, :star, :boolean
  end
end
