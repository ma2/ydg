class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :useid
      t.string :name
      t.integer :q1, default: 0
      t.integer :q2, default: 0
      t.integer :q3, default: 0
      t.integer :q4, default: 0
      t.integer :q5, default: 0

      t.timestamps
    end
  end
end
