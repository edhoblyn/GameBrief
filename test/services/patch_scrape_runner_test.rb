require "test_helper"

class PatchScrapeRunnerTest < ActiveSupport::TestCase
  test "runs the battlefield 6 importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 3, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::Battlefield6Importer.singleton_class
    original_new = PatchImporters::Battlefield6Importer.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("battlefield_6")

    assert_equal "battlefield_6", result.source
    assert_equal "Battlefield 6", result.label
    assert_equal 3, result.imported
    assert_equal 1, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "runs the baldur's gate 3 importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 5, skipped: 2)
      end
    end.new

    importer_class = PatchImporters::BaldursGate3Importer.singleton_class
    original_new = PatchImporters::BaldursGate3Importer.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("baldurs_gate_3")

    assert_equal "baldurs_gate_3", result.source
    assert_equal "Baldur's Gate 3", result.label
    assert_equal 5, result.imported
    assert_equal 2, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "runs the genshin impact importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 7, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::GenshinImpactImporter.singleton_class
    original_new = PatchImporters::GenshinImpactImporter.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("genshin_impact")

    assert_equal "genshin_impact", result.source
    assert_equal "Genshin Impact", result.label
    assert_equal 7, result.imported
    assert_equal 3, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "runs the arc raiders importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 4, skipped: 2)
      end
    end.new

    importer_class = PatchImporters::ArcRaidersImporter.singleton_class
    original_new = PatchImporters::ArcRaidersImporter.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("arc_raiders")

    assert_equal "arc_raiders", result.source
    assert_equal "ARC Raiders", result.label
    assert_equal 4, result.imported
    assert_equal 2, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "runs a configured importer" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 2, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::MarvelRivalsImporter.singleton_class
    original_new = PatchImporters::MarvelRivalsImporter.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("marvel_rivals")

    assert_equal "marvel_rivals", result.source
    assert_equal "Marvel Rivals", result.label
    assert_equal 2, result.imported
    assert_equal 1, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "raises on unknown source" do
    assert_raises(KeyError) do
      PatchScrapeRunner.run("unknown_game")
    end
  end

  test "runs the league of legends importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 6, skipped: 2)
      end
    end.new

    importer_class = PatchImporters::LeagueOfLegendsImporter.singleton_class
    original_new = PatchImporters::LeagueOfLegendsImporter.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("league_of_legends")

    assert_equal "league_of_legends", result.source
    assert_equal "League of Legends", result.label
    assert_equal 6, result.imported
    assert_equal 2, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "runs the counter-strike 2 importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 8, skipped: 3)
      end
    end.new

    importer_class = PatchImporters::CounterStrike2Importer.singleton_class
    original_new = PatchImporters::CounterStrike2Importer.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("counter_strike_2")

    assert_equal "counter_strike_2", result.source
    assert_equal "Counter-Strike 2", result.label
    assert_equal 8, result.imported
    assert_equal 3, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "runs the horizon forbidden west importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 5, skipped: 2)
      end
    end.new

    importer_class = PatchImporters::HorizonForbiddenWestImporter.singleton_class
    original_new = PatchImporters::HorizonForbiddenWestImporter.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("horizon_forbidden_west")

    assert_equal "horizon_forbidden_west", result.source
    assert_equal "Horizon Forbidden West", result.label
    assert_equal 5, result.imported
    assert_equal 2, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "runs the cyberpunk 2077 importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 4, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::Cyberpunk2077Importer.singleton_class
    original_new = PatchImporters::Cyberpunk2077Importer.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("cyberpunk_2077")

    assert_equal "cyberpunk_2077", result.source
    assert_equal "Cyberpunk 2077", result.label
    assert_equal 4, result.imported
    assert_equal 1, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "runs the spider-man 2 importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 6, skipped: 2)
      end
    end.new

    importer_class = PatchImporters::SpiderMan2Importer.singleton_class
    original_new = PatchImporters::SpiderMan2Importer.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("spider_man_2")

    assert_equal "spider_man_2", result.source
    assert_equal "Marvel's Spider-Man 2", result.label
    assert_equal 6, result.imported
    assert_equal 2, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "runs the pubg battlegrounds importer when configured" do
    importer = Class.new do
      Result = Struct.new(:imported, :skipped, keyword_init: true)

      def call
        Result.new(imported: 6, skipped: 1)
      end
    end.new

    importer_class = PatchImporters::PubgBattlegroundsImporter.singleton_class
    original_new = PatchImporters::PubgBattlegroundsImporter.method(:new)
    importer_class.define_method(:new) { importer }

    result = PatchScrapeRunner.run("pubg_battlegrounds")

    assert_equal "pubg_battlegrounds", result.source
    assert_equal "PUBG: Battlegrounds", result.label
    assert_equal 6, result.imported
    assert_equal 1, result.skipped
  ensure
    importer_class.define_method(:new, original_new)
  end

  test "treats blocked sources as non-scrapeable" do
    assert_not PatchScrapeRunner.scrapeable?("fortnite")
    assert_not PatchScrapeRunner.scrapeable?("destiny_2")
    assert_not PatchScrapeRunner.scrapeable?("helldivers_2")
    assert_not PatchScrapeRunner.scrapeable?("minecraft")
  end

  test "only returns scrapeable sources for runnable sources" do
    assert_includes PatchScrapeRunner.runnable_sources, "battlefield_6"
    assert_includes PatchScrapeRunner.runnable_sources, "baldurs_gate_3"
    assert_includes PatchScrapeRunner.runnable_sources, "genshin_impact"
    assert_includes PatchScrapeRunner.runnable_sources, "arc_raiders"
    assert_includes PatchScrapeRunner.runnable_sources, "apex_legends"
    assert_includes PatchScrapeRunner.runnable_sources, "league_of_legends"
    assert_includes PatchScrapeRunner.runnable_sources, "counter_strike_2"
    assert_includes PatchScrapeRunner.runnable_sources, "pubg_battlegrounds"
    assert_includes PatchScrapeRunner.runnable_sources, "overwatch_2"
    assert_includes PatchScrapeRunner.runnable_sources, "pokemon_pokopia"
    assert_includes PatchScrapeRunner.runnable_sources, "resident_evil_requiem"
    assert_includes PatchScrapeRunner.runnable_sources, "horizon_forbidden_west"
    assert_includes PatchScrapeRunner.runnable_sources, "cyberpunk_2077"
    assert_includes PatchScrapeRunner.runnable_sources, "spider_man_2"
    assert_includes PatchScrapeRunner.runnable_sources, "star_wars_battlefront_ii"
    assert_not_includes PatchScrapeRunner.runnable_sources, "fortnite"
    assert_not_includes PatchScrapeRunner.runnable_sources, "helldivers_2"
    assert_not_includes PatchScrapeRunner.runnable_sources, "minecraft"
  end
end
