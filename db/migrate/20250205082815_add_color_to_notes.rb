class AddColorToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :color, :string, default: "#FFFFFF", null: false
  end
end
