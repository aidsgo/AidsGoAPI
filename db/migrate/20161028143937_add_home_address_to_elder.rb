class AddHomeAddressToElder < ActiveRecord::Migration
  def change
    add_column :elders, :address, :string
  end
end
