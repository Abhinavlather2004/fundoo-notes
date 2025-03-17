class AddReminderToNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :reminder, :datetime, null: true
  end
end
