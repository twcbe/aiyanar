class PushNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "card_read_messages"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def notify

  end
end
