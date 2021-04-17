FactoryBot.define do
  factory :phone_number do
    number { rand(1000000000..9999999999) }
    account
  end
end