class GameSuggestionMailer < ApplicationMailer
  REVIEW_INBOX = ENV.fetch("GAME_SUGGESTIONS_TO", "gamebrief805@gmail.com")

  def game_suggestion_created(game_suggestion, user = nil)
    @game_suggestion = game_suggestion
    @user = user

    mail(
      to: REVIEW_INBOX,
      subject: "New game suggestion: #{@game_suggestion.name}"
    )
  end
end
