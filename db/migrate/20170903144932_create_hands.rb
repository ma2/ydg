class CreateHands < ActiveRecord::Migration[5.1]
  def change
    create_table :hands do |t|
      t.integer :value
      t.references :janken
      t.references :user

      t.timestamps
    end
  end
end
