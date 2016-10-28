class AddSerialNumberToElders < ActiveRecord::Migration
  def change
    add_column :elders, :serial_number, :string
  end
end
