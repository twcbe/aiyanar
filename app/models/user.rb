class User < ApplicationRecord
  validates :name, presence: true, allow_blank: false
  validates_uniqueness_of :employee_id, :allow_blank => true
  has_many :cards
  has_and_belongs_to_many :roles

end
