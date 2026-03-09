class Game < ApplicationRecord
  has_many :favourites, dependent: :destroy
  has_many :fans, through: :favourites, source: :user
  has_many :events, dependent: :destroy
  has_many :patches, dependent: :destroy
end
