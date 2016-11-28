class AddPhoneToElders < ActiveRecord::Migration
  def change
    add_column :elders, :phone, :string
    add_column :elders, :pwd, :string
    add_column :elders, :public_key, :string
  end
end
