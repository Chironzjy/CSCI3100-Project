class AddLocationLatitudeLongitudeToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :location, :string
    add_column :items, :latitude, :float
    add_column :items, :longitude, :float
  end
end
