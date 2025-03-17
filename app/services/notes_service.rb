class NotesService
  def self.get_all_notes(user)

    cache_key = "user_#{user.id}_notes"  # Unique cache key for each user
    
      # Try to get cached notes from Redis
      cached_notes = REDIS.get(cache_key)
    
      if cached_notes.present?
        Rails.logger.info "✅ Serving notes from Redis cache"
        return JSON.parse(cached_notes)  # Return cached data
      else
        Rails.logger.info "🔄 Fetching notes from DB and caching in Redis"
        notes = user.notes.where(isDeleted: false)  # Fetch from DB
    
        # Store the notes in Redis with a unique cache key
        REDIS.set(cache_key, notes.to_json)
    
        # Set an expiration time for the cached notes (10 minutes)
        # REDIS.expire(cache_key, 10.minutes.to_i)
    
        return notes
      end

    # begin
    #   user.notes.where(isDeleted: false) # Only fetch active notes of the logged-in user
    # rescue StandardError => e
    #   { success: false, errors: ["Failed to fetch notes: #{e.message}"] }
    # end
  end

  def self.create_note(user, note_params)

    cache_key = "user_#{user.id}_notes"
    note = user.notes.new(note_params)

    if note.save
      Rails.logger.info "🔍 Redis Keys Before: #{REDIS.keys('*')}"
      Rails.logger.info "🔄 Clearing cache in Redis"
      REDIS.del(cache_key)  # Delete cached notes so that fresh data is fetched
     
  
      Rails.logger.info "✅ Redis Keys After Deletion: #{REDIS.keys('*')}"
  
      return { success: true, note: note }  # ✅ Ensure proper hash return
    else
      return { success: false, errors: note.errors.full_messages }
    end


    # begin
    #   note = user.notes.build(note_params.merge(isDeleted: false))
    #   if note.save
    #     { success: true, note: note }
    #   else
    #     { success: false, errors: note.errors.full_messages }
    #   end
    # rescue StandardError => e
    #   { success: false, errors: ["Failed to create note: #{e.message}"] }
    # end
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
      note.update(is_archived: !note.isArchive)
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
  
  def self.set_reminder(note, reminder)
    reminder_time = reminder.present? ? Time.parse(reminder) : nil
    if note.update(reminder: reminder_time)
      { success: true, note: note }
    else
      { success: false, errors: note.errors.full_messages }
    end
  rescue ArgumentError => e
    { success: false, errors: ["Invalid reminder time format"] }
  end

end