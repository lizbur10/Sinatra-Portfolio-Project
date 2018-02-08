class AddDateSlugToReports < ActiveRecord::Migration[5.1]
  def change
    add_column :reports, :date_slug, :text
  end
end
