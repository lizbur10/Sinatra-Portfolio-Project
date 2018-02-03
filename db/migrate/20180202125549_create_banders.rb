class CreateBanders < ActiveRecord::Migration[5.1]
  def change
    create_table :banders do |t|
      t.string :name
      t.string :email
      t.string :password_digest
    end
  end
end
