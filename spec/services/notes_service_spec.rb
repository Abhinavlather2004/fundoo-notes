require 'rails_helper'

RSpec.describe NotesService, type: :service do
  let(:user) { create(:user) }
  let(:note) { create(:note, user: user) }
  let(:collaborator) { create(:user) }
  let(:valid_params) { {content: "This is a test" } }
  let(:cache_key) { "user_#{user.id}_notes" }

  before do
    allow(REDIS).to receive(:get).and_return(nil)
    allow(REDIS).to receive(:set)
    allow(REDIS).to receive(:del)
  end

  describe '.get_all_notes' do
    it 'fetches notes from the database if not cached' do
      expect(user.notes).to receive(:where).with(isDeleted: false).and_return([note])
      expect(REDIS).to receive(:set)
      NotesService.get_all_notes(user)
    end

    it 'returns cached notes if available' do
      allow(REDIS).to receive(:get).with(cache_key).and_return([note].to_json)
      expect(JSON).to receive(:parse).with([note].to_json)
      NotesService.get_all_notes(user)
    end
  end

  describe '.create_note' do
    it 'creates a note and clears cache' do
      expect { NotesService.create_note(user, valid_params) }.to change(Note, :count).by(1)
      expect(REDIS).to have_received(:del).with(cache_key)
    end
  end

  describe '.update_note' do
    it 'updates a note successfully' do
      result = NotesService.update_note(note, { content: 'Updated Content'  })
      expect(result[:success]).to be_truthy
      expect(note.reload.content).to eq('Updated Content')
    end
  end

  describe '.soft_delete_note' do
    it 'marks a note as deleted' do
      NotesService.soft_delete_note(note)
      expect(note.reload.isDeleted).to be_truthy
    end
  end

  describe '.toggle_archive' do
    it 'toggles archive status' do
      initial_status = note.isArchive
      NotesService.toggle_archive(note)
      expect(note.reload.isArchive).to eq(!initial_status)
    end
  end

  describe '.toggle_delete' do
    it 'toggles isDeleted field' do
      initial_status = note.isDeleted
      NotesService.toggle_delete(note)
      expect(note.reload.isDeleted).to eq(!initial_status)
    end
  end

  describe '.change_color' do
    it 'changes the note color' do
      NotesService.change_color(note, "#0000FF")
      expect(note.reload.color).to eq("#0000FF")
    end
  end

  describe '.add_collaborator' do
    it 'adds a collaborator successfully' do
      expect { NotesService.add_collaborator(note, collaborator) }.to change(Collaboration, :count).by(1)
    end

    it 'does not add the owner as a collaborator' do
      result = NotesService.add_collaborator(note, user)
      expect(result[:success]).to be_falsey
      expect(result[:errors]).to include("Owner cannot be added as a collaborator")
    end
  end
end
