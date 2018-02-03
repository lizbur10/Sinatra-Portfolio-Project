class ChangeNameOfIdColumnInSpecies < ActiveRecord::Migration[5.1]
  def change
    rename_column :all_species, :id, :species_id

  end
end
