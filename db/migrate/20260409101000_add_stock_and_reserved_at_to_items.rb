class AddStockAndReservedAtToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :stock_quantity, :integer, null: false, default: 1
    add_column :items, :reserved_at, :datetime
    add_index :items, :reserved_at
  end
end
