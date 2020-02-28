FactoryGirl.define do
  factory :message do
    message "Message"
    to "05499118599"
    from "05499128756"
    status MessageStatus::PENDING
    schedule nil
    message_type MessageType::SENT

    trait :sending do
      status MessageStatus::SENDING
    end

    trait :success do
      status MessageStatus::SUCCESS
    end

    trait :recently_created do
      message_type nil
    end

    trait :last_month_scheduled do
      created_at 1.month.ago - 1.day
      updated_at 1.month.ago
      schedule 1.month.ago
    end

    trait :next_month_scheduled do
      schedule 1.month.since
    end

    trait :current_month_scheduled do
      schedule DateTime.current
    end

    factory :message_with_problem, traits: [:sending] do
      updated_at 1.day.ago
    end
  end
end
