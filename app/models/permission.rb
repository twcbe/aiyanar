class Permission < ApplicationRecord
  belongs_to :lock
  belongs_to :role
end
