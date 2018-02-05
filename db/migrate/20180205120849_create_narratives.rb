class CreateNarratives < ActiveRecord::Migration[5.1]
  def change
    create_table :narratives do |t|
      t.string :date
    end
  end
end
