require "test_helper"

class PatchImporters::Gta5OnlineImporterTest < ActiveSupport::TestCase
  test "imports curated GTA 5: Online updates, updates existing ones, and removes placeholders" do
    game = Game.create!(name: "GTA 5: Online", slug: "gta-5-online")
    existing_patch = Patch.create!(
      game: game,
      title: "Old GTA title",
      content: "Old content",
      source_url: "https://support.rockstargames.com/articles/0ExWSr9Bvq5Putzsn5w54/gtav-title-update-1-72-notes-ps5-ps4-xbox-series-x-or-s-xbox-one-pc-enhanced",
      published_at: Time.zone.parse("2025-12-17")
    )
    placeholder_patch = Patch.create!(
      game: game,
      title: "Placeholder GTA patch",
      content: "Placeholder content",
      source_url: nil
    )

    result = PatchImporters::Gta5OnlineImporter.new.call

    assert_equal 1, result.imported
    assert_equal 1, result.skipped
    assert_equal "GTAV Title Update 1.72 Notes (PS5 / PS4 / Xbox Series X|S / Xbox One / PC [Enhanced/Legacy])", existing_patch.reload.title
    assert_includes existing_patch.content, "A Safehouse in the Hills"
    assert_equal Time.zone.parse("2026-02-11").to_i, existing_patch.published_at.to_i

    imported_patch = Patch.find_by(source_url: "https://support.rockstargames.com/articles/5IxfVX33w3X8fKooGKswfj/gtav-title-update-1-71-notes-ps5-ps4-xbox-series-x-or-s-xbox-one-pc-enhanced")
    assert_equal game, imported_patch.game
    assert_includes imported_patch.content, "Money Fronts"
    assert_nil Patch.find_by(id: placeholder_patch.id)
  end

  test "finds GTA 5: Online by legacy name when the slug differs" do
    game = Game.create!(name: "Grand Theft Auto V", slug: "legacy-grand-theft-auto-v")

    PatchImporters::Gta5OnlineImporter.new.call

    imported_patch = Patch.find_by(source_url: "https://support.rockstargames.com/articles/0ExWSr9Bvq5Putzsn5w54/gtav-title-update-1-72-notes-ps5-ps4-xbox-series-x-or-s-xbox-one-pc-enhanced")
    assert_equal game, imported_patch.game
  end

  test "raises when GTA 5: Online is missing" do
    assert_raises(ActiveRecord::RecordNotFound) do
      PatchImporters::Gta5OnlineImporter.new.call
    end
  end
end
