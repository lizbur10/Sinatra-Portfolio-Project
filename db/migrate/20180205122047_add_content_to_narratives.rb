class AddContentToNarratives < ActiveRecord::Migration[5.1]
  def change
    add_column :narratives, :content, :text

  end
end
