class Game < ApplicationRecord
  has_many :patches
  has_many :events
  has_many :favourites
end
