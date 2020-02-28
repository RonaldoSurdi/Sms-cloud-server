class MessageGroup < ActiveRecord::Base
  has_many :messages

  def total_sent
    messages
      .where("status = :success Or (status = :error And attempts >= :max_attempts)",
        success: MessageStatus::SUCCESS, error: MessageStatus::ERROR, max_attempts: Message::MAX_ATTEMPTS)
      .count
  end
end
