class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :priorities do |t|
      t.string :status, null: false
      t.timestamps
    end
    add_index :priorities, :status, unique: true

    create_table :tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.boolean :done, default: false
      t.string :title, null: false
      t.string :description, null: true
      t.timestamp :deadline, null: true
      t.references :priority, null: false
      t.timestamps
    end
  end
end
