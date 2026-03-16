require "test_helper"

class PatchPresentationServiceTest < ActiveSupport::TestCase
  test "stores formatted intro and sections from AI JSON" do
    game = Game.create!(name: "Presentation Game", slug: "presentation-game")
    patch = Patch.create!(
      game: game,
      title: "Patch 1.2",
      content: "Weapons\n- Rifle damage reduced\n\nModes\n- Ranked rewards updated",
      source_url: "https://example.com/patch/1-2"
    )

    client = ->(_prompt) do
      {
        "formatted_content" => "A balance-focused update with ranked follow-up.",
        "structured_sections" => [
          {
            "title" => "Weapon Balance",
            "summary" => "Rifles were toned down.",
            "content" => "- Rifle damage reduced"
          },
          {
            "title" => "Ranked",
            "summary" => "Rewards changed.",
            "content" => "- Ranked rewards updated"
          }
        ]
      }.to_json
    end

    PatchPresentationService.new(patch, client: client).call
    patch.reload

    assert_equal "A balance-focused update with ranked follow-up.", patch.formatted_content
    assert_equal 2, patch.structured_sections.size
    assert_equal "Weapon Balance", patch.structured_sections.first["title"]
    assert patch.ai_presentation_generated_at.present?
    assert_nil patch.ai_presentation_error
  end

  test "raises when AI returns unusable JSON" do
    game = Game.create!(name: "Broken Presentation Game", slug: "broken-presentation-game")
    patch = Patch.create!(
      game: game,
      title: "Patch 1.3",
      content: "Short notes",
      source_url: "https://example.com/patch/1-3"
    )

    error = assert_raises(PatchPresentationService::InvalidResponseError) do
      PatchPresentationService.new(patch, client: ->(_prompt) { "{\"structured_sections\":[]}" }).call
    end

    assert_match "no usable sections", error.message
    assert_match "no usable sections", patch.reload.ai_presentation_error
  end
end
