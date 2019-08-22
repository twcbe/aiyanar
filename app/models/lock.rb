class Lock < ApplicationRecord
  validates :name, presence: true, allow_blank: false, uniqueness: true
  belongs_to :room,class_name: "room", optional: true
end
