class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_FROM_EMAIL", "gamebrief805@gmail.com")
  layout "mailer"
end
