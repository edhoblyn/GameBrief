require "test_helper"

class PatchPresentationFallbackServiceTest < ActiveSupport::TestCase
  test "builds sections from heading and bullet content" do
    payload = PatchPresentationFallbackService.new(<<~TEXT).call
      Weapons
      - Rifle damage reduced
      - SMG recoil tightened

      Ranked
      - Rewards updated
    TEXT

    assert_nil payload[:formatted_content]
    assert_equal 2, payload[:structured_sections].size
    assert_equal "Weapons", payload[:structured_sections].first["title"]
    assert_includes payload[:structured_sections].first["content"], "- Rifle damage reduced"
    assert_equal "Ranked", payload[:structured_sections].last["title"]
  end

  test "falls back to a single section when no headings are present" do
    payload = PatchPresentationFallbackService.new(<<~TEXT).call
      - Rifle damage reduced
      - SMG recoil tightened
    TEXT

    assert_equal 1, payload[:structured_sections].size
    assert_equal "Patch Details", payload[:structured_sections].first["title"]
    assert_includes payload[:structured_sections].first["content"], "- Rifle damage reduced"
  end
end
