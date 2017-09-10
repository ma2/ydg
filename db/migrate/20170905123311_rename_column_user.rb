class RenameColumnUser < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :useid, :userid
  end
end
