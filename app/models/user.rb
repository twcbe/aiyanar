class User < ApplicationRecord
  validates :name, presence: true, allow_blank: false
  has_many :cards
  has_and_belongs_to_many :roles

end
