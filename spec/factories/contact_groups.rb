FactoryGirl.define do
  factory :contact_group do
    descricao { Faker::Lorem.words(2).join(" ").titleize }
    observacao { Faker::Lorem.paragraph if rand(3) == 0 }
  end

end
