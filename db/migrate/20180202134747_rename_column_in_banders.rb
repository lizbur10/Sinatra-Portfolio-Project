class RenameColumnInBanders < ActiveRecord::Migration[5.1]
  def change
    rename_column :banders, :password_digest, :password
  end
end
