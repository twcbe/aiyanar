class Card < ApplicationRecord
  belongs_to :user, optional: true
  validates :card_number, presence: true, allow_blank: false, uniqueness: true

  def to_s
    card_number
  end

end
