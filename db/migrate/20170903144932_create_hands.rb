class CreateHands < ActiveRecord::Migration[5.1]
  def change
    create_table :hands do |t|
      t.integer :value
      t.references :janken, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
