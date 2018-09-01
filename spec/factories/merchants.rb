# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    name { 'MyString' }
    logo { 'MyString' }
    address do
      <<~HEREDOC
        #<Mondo::Address {\"short_formatted\"=>\"Somewhere in Phoenix, 850340000
        , USA\", \"formatted\"=>\"Phoenix, 850340000, USA\", \"address\"=>\"\",
        \"city\"=>\"Phoenix\", \"region\"=>\"\", \"country\"=>\"USA\",
        \"postcode\"=>\"850340000\", \"latitude\"=>39.828175, \"longitude\"=>-98
        .5795, \"zoom_level\"=>2, \"approximate\"=>true}>
      HEREDOC
        .delete("\n")
    end
    monzo_id { 'MyString' }
    group_id { 'MyString' }
    created { '2018-08-20 13:03:10' }
    created_at { '2018-08-20 13:03:10' }
    updated_at { '2018-08-20 13:03:10' }
  end
end
