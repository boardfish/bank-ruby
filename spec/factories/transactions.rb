# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    amount { '9.99' }
    decline_reason { 'MyString' }
    is_load { false }
    settled { '2018-08-20 13:01:29' }
    created { '2018-08-20 13:01:29' }
    currency { 'MyString' }
    description { 'MyString' }
    notes { 'MyString' }
    created_at { '2018-08-20 13:01:29' }
    updated_at { '2018-08-20 13:01:29' }
    merchant_id { 1 }
    category_id { 1 }
    monzo_id { 'MyString' }
  end
end
