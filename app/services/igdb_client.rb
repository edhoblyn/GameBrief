class IgdbClient
  BASE_URL = "https://api.igdb.com/v4"
  TWITCH_AUTH_URL = "https://id.twitch.tv/oauth2/token"

  def initialize
    @client_id = ENV["TWITCH_CLIENT_ID"]
    @access_token = fetch_access_token
  end

  def search_games(query)
    uri = URI("#{BASE_URL}/games")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Client-ID"] = @client_id
    request["Authorization"] = "Bearer #{@access_token}"
    request.body = "search \"#{query}\"; fields name,slug,cover.url; limit 10;"

    response = http.request(request)
    JSON.parse(response.body)
  end

  def get_game(igdb_id)
    # TODO: implement if needed
    nil
  end

  private

  def fetch_access_token
    uri = URI(TWITCH_AUTH_URL)
    response = Net::HTTP.post_form(uri, {
      client_id: @client_id,
      client_secret: ENV["TWITCH_CLIENT_SECRET"],
      grant_type: "client_credentials"
    })
    JSON.parse(response.body)["access_token"]
  end
end
