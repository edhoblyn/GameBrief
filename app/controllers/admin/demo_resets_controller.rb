class Admin::DemoResetsController < Admin::BaseController
  DEMO_EMAIL = "demo@test.com"
  DEMO_GAME_NAMES = ["Marvel Rivals", "Call of Duty: Warzone", "Battlefield 6", "Minecraft", "Fortnite"].freeze
  PENDING_REQUESTER_EMAILS = ["shadowrex99@gamebrief.gg", "turbojack@gamebrief.gg", "grindsetgo@gamebrief.gg"].freeze
  ACCEPTED_FRIEND_EMAILS = ["pixelpete@gamebrief.gg", "cosmickai@gamebrief.gg", "novasprint@gamebrief.gg"].freeze

  def create
    demo_user = User.find_by(email: DEMO_EMAIL)

    unless demo_user
      return redirect_to admin_dashboard_path, alert: "Demo user (#{DEMO_EMAIL}) not found."
    end

    ActiveRecord::Base.transaction do
      # 1. Clear all favourites
      demo_user.favourites.destroy_all

      # 2. Clear all reminders
      demo_user.reminders.destroy_all

      # 3. Clear demo user's chats (cascades to messages)
      Chat.where(user: demo_user).destroy_all

      # 4. Restore pending friend requests (ShadowRex99, TurboJack, FragMaster99)
      requesters = User.where(email: PENDING_REQUESTER_EMAILS)
      requesters.each do |requester|
        fs = Friendship.find_or_initialize_by(user: requester, friend: demo_user)
        fs.status = "pending"
        fs.save!
      end

      # 5. Ensure accepted friends are still accepted (pixelpete, cosmickai, novasprint)
      accepted_friends = User.where(email: ACCEPTED_FRIEND_EMAILS)
      accepted_friends.each do |friend|
        fs = Friendship.find_or_initialize_by(user: demo_user, friend: friend)
        fs.status = "accepted"
        fs.save!
      end
    end

    redirect_to admin_dashboard_path,
                notice: "Demo profile reset — favourites cleared, reminders cleared, chats cleared, friend requests restored."
  end
end
