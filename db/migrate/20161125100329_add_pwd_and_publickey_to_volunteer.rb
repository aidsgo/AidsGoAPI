class AddPwdAndPublickeyToVolunteer < ActiveRecord::Migration
  def change
    add_column :volunteers, :pwd, :string
    add_column :volunteers, :public_key, :string
    add_column :volunteers, :phone, :string
  end
end
