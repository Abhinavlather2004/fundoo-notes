class Api::V1::NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:update_note, :toggle_archive, :change_color, :add_collaborator, :toggle_delete]

  def get_all_notes
    begin
      notes = Rails.cache.fetch("user_#{current_user.id}_notes", expires_in: 10.minutes) do
        current_user.notes.where(isDeleted: false).to_a + current_user.shared_notes.where(isDeleted: false).to_a
      end
      render json: notes, status: :ok
    rescue => e
      render json: { error: "Failed to fetch notes", message: e.message }, status: :internal_server_error
    end
  end

  def create_note
    begin
      note = NotesService.create_note(current_user, note_params)
      if note[:success]
        Rails.cache.delete("user_#{current_user.id}_notes") # Invalidate cache
        render json: note[:note], status: :created
      else
        render json: { errors: note[:errors] }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: "Failed to create note", message: e.message }, status: :internal_server_error
    end
  end

  def update_note
    begin
      result = NotesService.update_note(@note, note_params)
      if result[:success]
        Rails.cache.delete("user_#{current_user.id}_notes") # Invalidate cache
        render json: result[:note], status: :ok
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: "Failed to update note", message: e.message }, status: :internal_server_error
    end
  end

  def toggle_archive
    begin
      result = NotesService.toggle_archive(@note)
      if result[:success]
        Rails.cache.delete("user_#{current_user.id}_notes") # Invalidate cache
        render json: result[:note], status: :ok
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: "Failed to toggle archive status", message: e.message }, status: :internal_server_error
    end
  end

  def toggle_delete
    begin
      result = NotesService.toggle_delete(@note)
      if result[:success]
        Rails.cache.delete("user_#{current_user.id}_notes") # Invalidate cache
        render json: result[:note], status: :ok
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: "Failed to toggle delete status", message: e.message }, status: :internal_server_error
    end
  end

  def change_color
    begin
      result = NotesService.change_color(@note, params[:color])
      if result[:success]
        Rails.cache.delete("user_#{current_user.id}_notes") # Invalidate cache
        render json: result[:note], status: :ok
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: "Failed to change note color", message: e.message }, status: :internal_server_error
    end
  end

  def add_collaborator
    begin
      collaborator = User.find_by(email: params[:email])
      return render json: { error: "User not found" }, status: :not_found if collaborator.nil?

      result = NotesService.add_collaborator(@note, collaborator)
      if result[:success]
        Rails.cache.delete("user_#{current_user.id}_notes") # Invalidate cache
        render json: { message: "Collaborator added successfully", note: @note }, status: :ok
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: "Failed to add collaborator", message: e.message }, status: :internal_server_error
    end
  end

  private

  def set_note
    @note = current_user.shared_notes.find_by(id: params[:id]) || current_user.notes.find_by(id: params[:id])
    render json: { error: "Note not found or unauthorized" }, status: :not_found if @note.nil?
  rescue => e
    render json: { error: "Failed to fetch note", message: e.message }, status: :internal_server_error
  end

  def note_params
    params.require(:note).permit(:title, :content, :color, :isDeleted, :isArchive)
  end
end
