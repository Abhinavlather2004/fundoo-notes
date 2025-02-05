class NotesService
  def self.get_all_notes(user)
    begin
      user.notes.where(isDeleted: false) # Only fetch active notes of the logged-in user
    rescue StandardError => e
      { success: false, errors: ["Failed to fetch notes: #{e.message}"] }
    end
  end

  def self.create_note(user, note_params)
    begin
      note = user.notes.build(note_params.merge(isDeleted: false))
      if note.save
        { success: true, note: note }
      else
        { success: false, errors: note.errors.full_messages }
      end
    rescue StandardError => e
      { success: false, errors: ["Failed to create note: #{e.message}"] }
    end
  end

  def self.update_note(note, note_params)
    begin
      if note.update(note_params)
        { success: true, note: note }
      else
        { success: false, errors: note.errors.full_messages }
      end
    rescue StandardError => e
      { success: false, errors: ["Failed to update note: #{e.message}"] }
    end
  end

  def self.soft_delete_note(note)
    begin
      note.update(isDeleted: true)
    rescue StandardError => e
      { success: false, errors: ["Failed to delete note: #{e.message}"] }
    end
  end

  def self.toggle_archive(note)
    begin
      note.update(isArchive: !note.isArchive)
      if note.save
        { success: true, note: note }
      else
        { success: false, errors: note.errors.full_messages }
      end
    rescue StandardError => e
      { success: false, errors: ["Failed to toggle archive: #{e.message}"] }
    end
  end

  def self.toggle_delete(note)
    begin
      new_is_deleted = !note.isDeleted
      if note.update(isDeleted: new_is_deleted)
        { success: true, note: note }
      else
        { success: false, errors: note.errors.full_messages }
      end
    rescue StandardError => e
      { success: false, errors: ["Failed to toggle delete: #{e.message}"] }
    end
  end

  def self.change_color(note, color)
    begin
      if note.update(color: color)
        { success: true, note: note }
      else
        { success: false, errors: note.errors.full_messages }
      end
    rescue StandardError => e
      { success: false, errors: ["Failed to change color: #{e.message}"] }
    end
  end

  def self.add_collaborator(note, collaborator)
    begin
      if note.user_id == collaborator.id
        return { success: false, errors: ["Owner cannot be added as a collaborator"] }
      end

      collaboration = Collaboration.new(user: collaborator, note: note)
      if collaboration.save
        { success: true, note: note }
      else
        { success: false, errors: collaboration.errors.full_messages }
      end
    rescue StandardError => e
      { success: false, errors: ["Failed to add collaborator: #{e.message}"] }
    end
  end
end
