class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.string :project_name, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :projects, :project_name, unique: true
  end
end
