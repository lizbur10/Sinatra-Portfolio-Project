class CreateReports < ActiveRecord::Migration[5.1]
  def change
    create_table :reports do |t|
      t.string :date
      t.string :date_slug
      t.string :content
      t.string :status
      t.integer :bander_id
    end
  end
end
