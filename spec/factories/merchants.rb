# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    name { 'MyString' }
    logo { 'MyString' }
    address { 'MyString' }
    monzo_id { 'MyString' }
    group_id { 'MyString' }
    created { '2018-08-20 13:03:10' }
    created_at { '2018-08-20 13:03:10' }
    updated_at { '2018-08-20 13:03:10' }
  end
end
