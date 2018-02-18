class AddReportIdToBirds < ActiveRecord::Migration[5.1]
  def change
    add_column :birds, :report_id, :integer
  end
end
