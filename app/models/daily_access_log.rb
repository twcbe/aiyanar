class DailyAccessLog < ApplicationRecord
  belongs_to :user
  belongs_to :lock

  include ::BelongsToUser

  attribute :date, :date
  attribute :first_enter, :datetime
  attribute :last_enter, :datetime
  attribute :first_exit, :datetime
  attribute :last_exit, :datetime

  ransacker :date, type: :date do
    Arel.sql('date(date)')
  end
end
