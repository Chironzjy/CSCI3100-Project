class AddLocationAndUsernameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :location, :string
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
    add_column :users, :username, :string
  end
end
