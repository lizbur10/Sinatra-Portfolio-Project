class AddStatusToReports < ActiveRecord::Migration[5.1]
  def change
    add_column :reports, :status, :text
  end
end
