class Lock < ApplicationRecord
  validates :name, presence: true, allow_blank: false, uniqueness: true
  belongs_to :room, optional: true
end
