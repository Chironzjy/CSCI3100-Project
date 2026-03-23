class AddCollegeAndVisibilityFields < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :college, :string
    add_index :users, :college

    add_column :items, :visibility_scope, :string, null: false, default: "campus"
    add_column :items, :visibility_college, :string
    add_index :items, :visibility_scope
    add_index :items, :visibility_college
  end
end