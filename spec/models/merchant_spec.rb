# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Merchant, type: :model do
  it 'should have a unique Monzo ID' do
    FactoryBot.build(:merchant).save
    duplicate_merchant = FactoryBot.build(:merchant)
    duplicate_merchant.valid?
    expect(duplicate_merchant.errors[:monzo_id])
      .to include('has already been taken')
  end
end
