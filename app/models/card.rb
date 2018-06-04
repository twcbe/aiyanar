class Card < ApplicationRecord
  belongs_to :user, optional: true

  def to_s
    card_number
  end

end
