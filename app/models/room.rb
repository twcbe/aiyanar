class Room < ApplicationRecord
	validates :name, uniqueness: true, presence: true, allow_blank: false
	has_many :locks
end
