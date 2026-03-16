class AddAiPresentationFieldsToPatches < ActiveRecord::Migration[8.1]
  def change
    add_column :patches, :formatted_content, :text
    add_column :patches, :structured_sections, :jsonb, default: [], null: false
    add_column :patches, :ai_presentation_requested_at, :datetime
    add_column :patches, :ai_presentation_generated_at, :datetime
    add_column :patches, :ai_presentation_error, :text
  end
end
