class AddInfoToEmergencies < ActiveRecord::Migration
  def change
    add_column :emergencies, :accept, :jsonb
    add_column :emergencies, :reject, :jsonb
  end
end
