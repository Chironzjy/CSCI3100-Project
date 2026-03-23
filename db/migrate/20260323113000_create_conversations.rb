class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :item, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :conversations, [:item_id, :buyer_id, :seller_id], unique: true, name: "index_conversations_on_item_buyer_seller"
  end
end
