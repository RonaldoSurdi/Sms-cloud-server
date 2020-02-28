FactoryGirl.define do
  factory :role do
    description { Faker::Lorem.words(rand(2) + 1).join(' ').titleize }
  end
end
