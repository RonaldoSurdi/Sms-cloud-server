FactoryGirl.define do
  factory :configuration, class: 'Configuration' do
    send_birthdays true
    text_birthdays "Hello World!"
  end
end
