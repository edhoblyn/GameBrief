require "test_helper"

class Scrapers::GenshinImpactScraperTest < ActiveSupport::TestCase
  test "collects official genshin impact update posts from hoyolab" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::GenshinImpactScraper.new
      list_payload = genshin_list_payload
      detail_payloads = genshin_detail_payloads

      scraper.define_singleton_method(:request_json) do |base_url, params|
        case base_url
        when self.class::LIST_URL
          list_payload
        when self.class::DETAIL_URL
          detail_payloads.fetch(params.fetch(:post_id).to_s)
        else
          raise "unexpected URL #{base_url}"
        end
      end

      results = scraper.call

      assert_equal 4, results.size

      latest_patch = results.first
      assert_equal "Version Luna V Version Details - What's New(03/05)", latest_patch[:title]
      assert_equal "https://www.hoyolab.com/article/43970902", latest_patch[:source_url]
      assert_equal Time.zone.parse("2026-02-27T07:46:00Z").to_i, latest_patch[:published_at].to_i
      assert_includes latest_patch[:content], "Dear Travelers:"
      assert_includes latest_patch[:content], "Version Luna V fixes several gameplay issues."

      update_details = results.second
      assert_equal "\"Song of the Welkin Moon: Variation — Homeward, He Who Caught the Wind\": Version \"Luna V\" Update Details", update_details[:title]
      assert_equal Time.zone.parse("2026-02-24T03:00:04Z").to_i, update_details[:published_at].to_i
      assert_includes update_details[:content], "Compensation Details"
      assert_includes update_details[:content], "- Maintenance Compensation: Primogems x300."

      maintenance_preview = results.third
      assert_equal "Version \"Luna V\" Update Maintenance Preview", maintenance_preview[:title]
      assert_includes maintenance_preview[:content], "Update Schedule"
      assert_includes maintenance_preview[:content], "- Maintenance begins 2026/02/25 06:00 (UTC+8)."

      issue_fix = results.fourth
      assert_equal "Issue Fix Details", issue_fix[:title]
      assert_equal Time.zone.parse("2025-10-20T01:30:00Z").to_i, issue_fix[:published_at].to_i
      assert_includes issue_fix[:content], "Bug Fixes"
      assert_includes issue_fix[:content], "- Fixed an issue with reward delivery timing."
    end
  end

  private

  def genshin_list_payload
    {
      "retcode" => 0,
      "message" => "OK",
      "data" => {
        "list" => [
          list_item("43970902", "Version Luna V Version Details - What's New(03/05)", "1015537", "2026-02-27T07:46:00Z"),
          list_item("43935248", "\"Song of the Welkin Moon: Variation — Homeward, He Who Caught the Wind\": Version \"Luna V\" Update Details", "1015537", "2026-02-24T03:00:04Z"),
          list_item("43918162", "Version \"Luna V\" Update Maintenance Preview", "1015537", "2026-02-23T03:00:08Z"),
          list_item("43581824", "Issue Fix Details", "1015537", "2025-10-20T01:30:00Z"),
          list_item("44193093", "Another Star Goes Out — Notes on Skirk", "1015537", "2026-03-13T12:00:05Z"),
          list_item("99999999", "Version Luna II Version Details - What's New (09/01)", "1015537", "2025-09-01T09:00:00Z"),
          list_item("88888888", "Version Luna V Update Maintenance Preview", "206178201", "2026-02-23T03:00:08Z")
        ]
      }
    }
  end

  def genshin_detail_payloads
    {
      "43970902" => detail_payload(
        post_id: "43970902",
        title: "Version Luna V Version Details - What's New(03/05)",
        published_at: "2026-02-27T07:46:00Z",
        body: <<~HTML
          <p>Dear Travelers:</p>
          <p>Version Luna V fixes several gameplay issues.</p>
          <ul>
            <li>Character Trials refreshed.</li>
            <li>Spiral Abyss lineup updated.</li>
          </ul>
        HTML
      ),
      "43935248" => detail_payload(
        post_id: "43935248",
        title: "\"Song of the Welkin Moon: Variation — Homeward, He Who Caught the Wind\": Version \"Luna V\" Update Details",
        published_at: "2026-02-24T03:00:04Z",
        body: <<~HTML
          <h2>Compensation Details</h2>
          <ul>
            <li>Maintenance Compensation: Primogems x300.</li>
            <li>Issue Fix Compensation: Primogems x300.</li>
          </ul>
        HTML
      ),
      "43918162" => detail_payload(
        post_id: "43918162",
        title: "Version \"Luna V\" Update Maintenance Preview",
        published_at: "2026-02-23T03:00:08Z",
        body: <<~HTML
          <h2>Update Schedule</h2>
          <ul>
            <li>Maintenance begins 2026/02/25 06:00 (UTC+8).</li>
            <li>Maintenance is expected to take 5 hours.</li>
          </ul>
        HTML
      ),
      "43581824" => detail_payload(
        post_id: "43581824",
        title: "Issue Fix Details",
        published_at: "2025-10-20T01:30:00Z",
        body: <<~HTML
          <h2>Bug Fixes</h2>
          <ul>
            <li>Fixed an issue with reward delivery timing.</li>
            <li>Fixed an issue causing a notification loop.</li>
          </ul>
        HTML
      )
    }
  end

  def list_item(post_id, title, user_id, published_at)
    {
      "post" => {
        "post_id" => post_id,
        "subject" => title,
        "created_at" => Time.zone.parse(published_at).to_i
      },
      "user" => {
        "uid" => user_id,
        "nickname" => "Genshin Impact Official"
      }
    }
  end

  def detail_payload(post_id:, title:, published_at:, body:)
    {
      "retcode" => 0,
      "message" => "OK",
      "data" => {
        "post" => {
          "post" => {
            "post_id" => post_id,
            "subject" => title,
            "content" => body,
            "created_at" => Time.zone.parse(published_at).to_i,
            "structured_content" => "[]"
          }
        }
      }
    }
  end
end
