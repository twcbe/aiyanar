class Role < ApplicationRecord
  validates :name, presence: true, allow_blank: false, uniqueness: true
  has_and_belongs_to_many :users
end
