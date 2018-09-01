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

  it 'should return an address hash' do
    merchant = FactoryBot.build(:merchant)
    merchant.save
    expect(merchant.address_data['short_formatted'])
      .to eq('Somewhere in Phoenix, 850340000, USA')
  end

  it 'should return nil if no address is stored' do
    merchant = FactoryBot.build(:merchant, address: nil)
    merchant.save
    expect(merchant.address_data).to be nil
  end
end
