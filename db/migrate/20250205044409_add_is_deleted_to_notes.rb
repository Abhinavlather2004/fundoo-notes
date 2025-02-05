class AddIsDeletedToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :isDeleted, :boolean, default: false, null: false
  end
end
