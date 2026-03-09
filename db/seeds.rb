# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Cleaning database..."

Reminder.destroy_all
Event.destroy_all
PatchSummary.destroy_all
Patch.destroy_all
Favourite.destroy_all
Game.destroy_all
User.destroy_all

puts "Creating users..."

user = User.create!(
  email: "demo@test.com",
  password: "123456"
)

puts "Importing games from IGDB..."

client = IgdbClient.new

def import_game(client, query)
  results = client.search_games(query)
  match = results.find { |g| g["name"]&.downcase == query.downcase && g["cover"] }
  match ||= results.find { |g| g["cover"] }
  match ||= results.first
  return nil unless match

  cover_url = match["cover"] ? "https:#{match["cover"]["url"].gsub("t_thumb", "t_cover_big")}" : nil

  Game.create!(
    name: match["name"],
    slug: match["slug"],
    cover_image: cover_url
  )
end

fortnite = import_game(client, "Fortnite")
destiny  = import_game(client, "Destiny 2")
apex     = import_game(client, "Apex Legends")

puts "Creating patches..."

fortnite_patch = Patch.create!(
  game: fortnite,
  title: "Chapter 6 Balance Update",
  content: "Major weapon balance changes and new map areas added."
)

destiny_patch = Patch.create!(
  game: destiny,
  title: "Season of Echoes",
  content: "New raid, seasonal weapons, and sandbox changes."
)

apex_patch = Patch.create!(
  game: apex,
  title: "Mid-Season Update",
  content: "Legend balance adjustments and new limited-time mode."
)

puts "Creating patch summaries..."

PatchSummary.create!(
  patch: fortnite_patch,
  summary: "Weapon balance updated and new map zones added."
)

PatchSummary.create!(
  patch: destiny_patch,
  summary: "New raid and seasonal gear introduced."
)

PatchSummary.create!(
  patch: apex_patch,
  summary: "Legend balance changes and new game mode."
)

puts "Creating events..."

Event.create!(
  game: fortnite,
  title: "Fortnite Live Event",
  description: "End of season live event",
  start_date: DateTime.now + 7.days
)

Event.create!(
  game: destiny,
  title: "Iron Banner",
  description: "Limited-time PvP event",
  start_date: DateTime.now + 5.days
)

Event.create!(
  game: apex,
  title: "Collection Event",
  description: "Limited cosmetics and challenges",
  start_date: DateTime.now + 10.days
)

puts "Seeds finished!"
