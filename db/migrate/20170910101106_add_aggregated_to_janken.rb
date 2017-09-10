class AddAggregatedToJanken < ActiveRecord::Migration[5.1]
  def change
    add_column :jankens, :aggregated, :boolean, default: false
  end
end
