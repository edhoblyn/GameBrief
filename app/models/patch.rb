class Patch < ApplicationRecord
  belongs_to :game
  has_many :patch_summaries, dependent: :destroy
end
