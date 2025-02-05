class AddIsArchiveToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :isArchive, :boolean, default: false, null: false
  end
end
