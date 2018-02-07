class RenameNarrativesTable < ActiveRecord::Migration[5.1]
  def change
    rename_table :narratives, :reports
  end
end
