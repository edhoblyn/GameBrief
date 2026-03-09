class IgdbClient
  BASE_URL = "https://api.igdb.com/v4"

  def initialize
    @client_id = ENV["TWITCH_CLIENT_ID"]
    @access_token = fetch_access_token
  end

  def search_games(query)
    # TODO: implement game search
    []
  end

  def get_game(igdb_id)
    # TODO: implement single game fetch
    nil
  end

  private

  def fetch_access_token
    # TODO: implement Twitch OAuth token fetch
    nil
  end
end
