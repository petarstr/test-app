class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.references :task, null: false
      t.string :comment, null: false
      t.timestamps
    end
  end
end
