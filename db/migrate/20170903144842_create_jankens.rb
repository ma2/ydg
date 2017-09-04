class CreateJankens < ActiveRecord::Migration[5.1]
  def change
    create_table :jankens do |t|
      t.string :jid

      t.timestamps
    end
  end
end
