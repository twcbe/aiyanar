class Card < ApplicationRecord
  belongs_to :user, optional: true
end
