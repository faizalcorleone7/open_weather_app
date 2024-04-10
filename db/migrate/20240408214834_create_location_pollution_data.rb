class CreateLocationPollutionData < ActiveRecord::Migration[7.1]
  def up
    return if table_exists? :location_pollution_data
    create_table :location_pollution_data do |t|
      t.bigint :location_id
      t.float :aqi
      t.float :co
      t.float :no
      t.float :no2
      t.float :ozone
      t.float :so2
      t.float :pm2
      t.float :pm10
      t.float :nh3
      t.timestamps
    end

    add_foreign_key(:location_pollution_data, :locations)

  end

  def down
    drop_table :location_pollution_data if table_exists? :location_pollution_data
  end
end
