class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies, id: :uuid do |t|
      t.uuid :elder_id,  null: false
      t.jsonb :elder_location
      t.uuid :resolved

      t.timestamps null: false
    end
  end
end
