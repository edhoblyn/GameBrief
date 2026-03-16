require "test_helper"

class Scrapers::SpiderMan2ScraperTest < ActiveSupport::TestCase
  test "collects official spider-man 2 pc patch notes from steam news data" do
    travel_to Time.zone.local(2026, 3, 16, 12, 0, 0) do
      scraper = Scrapers::SpiderMan2Scraper.new
      html = index_html
      scraper.define_singleton_method(:fetch_document) do |_url|
        Nokogiri::HTML(html)
      end

      results = scraper.call

      assert_equal 4, results.size

      latest_patch = results.first
      assert_equal "Marvel's Spider-Man 2 PC - Patch 10 Hotfix", latest_patch[:title]
      assert_equal "https://store.steampowered.com/news/app/2651280/view/530973313390871694", latest_patch[:source_url]
      assert_equal Time.zone.parse("2025-05-28T15:00:00+00:00").to_i, latest_patch[:published_at].to_i
      assert_includes latest_patch[:content], "Release Notes (1.526.0.0)"
      assert_includes latest_patch[:content], "- Fixed an issue that prevented AMD FSR Frame Generation from generating new frames."

      patch_ten = results.second
      assert_equal "Marvel's Spider-Man 2 PC – Patch 10 Release Notes", patch_ten[:title]
      assert_equal Time.zone.parse("2025-05-22T15:00:00+00:00").to_i, patch_ten[:published_at].to_i
      assert_includes patch_ten[:content], "- Integrated NVIDIA DLSS 4 with Transformer model for upscaling and Multi Frame Generation for supported GPUs."

      patch_six = results.third
      assert_equal "Marvel's Spider-Man 2 PC – Patch 6 Release Notes", patch_six[:title]
      assert_equal Time.zone.parse("2025-03-20T15:00:00+00:00").to_i, patch_six[:published_at].to_i
      assert_includes patch_six[:content], "- Updated Intel XeSS upscaling to version 2.0.1. This fixes bright visual artefacts that could occur when using XeSS upscaling."

      patch_one = results.fourth
      assert_equal "Marvel’s Spider-Man 2 PC – Patch 1 Release Notes", patch_one[:title]
      assert_equal Time.zone.parse("2025-02-06T15:00:00+00:00").to_i, patch_one[:published_at].to_i
      assert_includes patch_one[:content], "- Various crash fixes and stability improvements."
    end
  end

  private

  def index_html
    latest_time = Time.zone.parse("2025-05-28T15:00:00+00:00").to_i
    patch_ten_time = Time.zone.parse("2025-05-22T15:00:00+00:00").to_i
    patch_six_time = Time.zone.parse("2025-03-20T15:00:00+00:00").to_i
    patch_one_time = Time.zone.parse("2025-02-06T15:00:00+00:00").to_i
    stale_time = Time.zone.parse("2023-12-10T15:00:00+00:00").to_i

    payload = {
      "documents" => [
        { "unique_id" => "530973313390871694", "event_type" => 12, "start_time" => latest_time },
        { "unique_id" => "530973313390870870", "event_type" => 13, "start_time" => patch_ten_time },
        { "unique_id" => "536596558933657553", "event_type" => 13, "start_time" => patch_six_time },
        { "unique_id" => "500564506841186817", "event_type" => 13, "start_time" => patch_one_time },
        { "unique_id" => "111111111111111111", "event_type" => 13, "start_time" => stale_time }
      ],
      "events" => [
        event_payload(
          gid: "530973313390871694",
          event_type: 12,
          published_at: "2025-05-28T15:00:00+00:00",
          headline: "Marvel's Spider-Man 2 PC - Patch 10 Hotfix",
          body: <<~BODY
            Hey everyone,

            [H3]Release Notes (1.526.0.0)[/h3]
            [list]
            [*]Fixed an issue that prevented AMD FSR Frame Generation from generating new frames.
            [/list]
          BODY
        ),
        event_payload(
          gid: "530973313390870870",
          event_type: 13,
          published_at: "2025-05-22T15:00:00+00:00",
          headline: "Marvel's Spider-Man 2 PC – Patch 10 Release Notes",
          body: <<~BODY
            Hey everyone,

            [h3]Release Notes (1.520.0.0)[/h3]
            [list]
            [*]Integrated NVIDIA DLSS 4 with Transformer model for upscaling and Multi Frame Generation for supported GPUs.
            [*]Stability improvements.
            [/list]
          BODY
        ),
        event_payload(
          gid: "536596558933657553",
          event_type: 13,
          published_at: "2025-03-20T15:00:00+00:00",
          headline: "Marvel's Spider-Man 2 PC – Patch 6 Release Notes",
          body: <<~BODY
            [h3]Release Notes (1.318.1.0)[/h3]
            [list]
            [*]Updated Intel XeSS upscaling to version 2.0.1. This fixes bright visual artefacts that could occur when using XeSS upscaling.
            [*]Various stability improvements.
            [/list]
          BODY
        ),
        event_payload(
          gid: "500564506841186817",
          event_type: 13,
          published_at: "2025-02-06T15:00:00+00:00",
          headline: "Marvel’s Spider-Man 2 PC – Patch 1 Release Notes",
          body: <<~BODY
            [list]
            [*]Various crash fixes and stability improvements.
            [*]Improved some mission checkpoints.
            [/list]
          BODY
        ),
        event_payload(
          gid: "111111111111111111",
          event_type: 13,
          published_at: "2023-12-10T15:00:00+00:00",
          headline: "Marvel's Spider-Man 2 PC – Patch 0 Release Notes",
          body: "[list][*]Old notes.[/list]"
        ),
        event_payload(
          gid: "222222222222222222",
          event_type: 28,
          published_at: "2025-02-20T15:00:00+00:00",
          headline: "Marvel's Spider-Man 2 is Steam Deck Verified!",
          body: "[list][*]Promo copy.[/list]"
        )
      ]
    }

    <<~HTML
      <html>
        <body>
          <div id="application_config" data-initialEvents="#{CGI.escapeHTML(payload.to_json)}"></div>
        </body>
      </html>
    HTML
  end

  def event_payload(gid:, event_type:, published_at:, headline:, body:)
    {
      "gid" => gid,
      "event_type" => event_type,
      "rtime32_start_time" => Time.zone.parse(published_at).to_i,
      "announcement_body" => {
        "headline" => headline,
        "body" => body,
        "posttime" => Time.zone.parse(published_at).to_i
      }
    }
  end
end
