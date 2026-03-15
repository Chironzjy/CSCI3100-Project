class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.string  :title,       null: false
      t.text    :description
      t.decimal :price,       precision: 10, scale: 2, null: false, default: 0
      t.string  :status,      null: false, default: 'available'
      t.string  :category
      t.string  :college
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :items, :status
    add_index :items, :category
  end
end
