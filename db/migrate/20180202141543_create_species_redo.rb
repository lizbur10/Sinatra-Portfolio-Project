class CreateSpeciesRedo < ActiveRecord::Migration[5.1]
  def change
    create_table :all_species do |t|
      t.string :code
      t.string :name
    end
  end
end
