class CreateVolunteers < ActiveRecord::Migration
  def change
    create_table :volunteers do |t|
      t.string :name
      t.date :birthday
      t.string :sex
      t.string :community
      t.string :image
      t.jsonb :contact
      t.integer :help_count
      t.jsonb :emergency_call

      t.timestamps null: false
    end
  end
end
