# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it 'must have a unique Monzo ID' do
    FactoryBot.build(:transaction).save
    duplicate_transaction = FactoryBot.build(:transaction)
    duplicate_transaction.valid?
    expect(duplicate_transaction.errors[:monzo_id])
      .to include('has already been taken')
  end

  pending 'has all given info when created by a request to monzo_webhook_add' do
  end

  pending 'has all given info when created via seeding' do
  end
end
