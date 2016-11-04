class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
      t.uuid :elder_id,  null: false
      t.jsonb :elder_location
      t.uuid :resolved

      t.timestamps null: false
    end
  end
end
