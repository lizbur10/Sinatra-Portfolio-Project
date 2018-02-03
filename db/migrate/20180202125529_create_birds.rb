class CreateBirds < ActiveRecord::Migration[5.1]
  def change
    create_table :birds do |t|
      t.string :banding_date
      t.integer :bander_id
      t.integer :species_id
    end
  end
end
