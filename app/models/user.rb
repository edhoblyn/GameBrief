class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         # for Google OmniAuth
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :favourites, dependent: :destroy
  has_many :favourite_games, through: :favourites, source: :game
  has_many :reminders, dependent: :destroy

  def admin?
    has_attribute?(:role) && self[:role] == "admin"
  end

  def self.from_omniauth(auth)
    # Find or create a user based on the provider and uid
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20] # Generate a random password
    end
  end
end
