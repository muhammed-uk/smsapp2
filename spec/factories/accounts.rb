FactoryBot.define do
  sequence :username do |n|
    "user-#{n}"
  end

  sequence :auth_id do |n|
    "passcode-#{n}"
  end

  factory :account do
    username
    auth_id
  end
end
