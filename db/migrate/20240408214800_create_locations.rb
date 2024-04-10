class CreateLocations < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :locations
    create_table :locations do |t|
      t.string :zip
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :country
      t.timestamps
    end
  end

  def down
    drop_table :locations if table_exists? :locations
  end
end
