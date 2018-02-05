class AddBanderIdToNarratives < ActiveRecord::Migration[5.1]
  def change
    add_column :narratives, :bander_id, :integer
  end
end
