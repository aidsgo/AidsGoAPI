class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
      t.integer :elder_id,  null: false
      t.jsonb :elder_location
      t.boolean :emergency_validation

      t.timestamps null: false
    end
  end
end
