class MakeZipUnique < ActiveRecord::Migration[7.1]
  def up
    if table_exists? :locations
      add_index :locations, :zip, name: "custom_index_name", unique: true
    end
  end

  def down
    remove_index :locations, name: "custom_index_name"
  end
end
