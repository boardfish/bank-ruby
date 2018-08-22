# frozen_string_literal: true

require 'rails_helper'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
end

RSpec.describe Transaction, type: :model do
  let(:client) { initialize_mondo_client }
  let(:transaction) { client.transaction('tx_00009PCgONNoDdKBkR1Jw1') }

  it 'must have a unique Monzo ID' do
    FactoryBot.build(:transaction).save
    duplicate_transaction = FactoryBot.build(:transaction)
    duplicate_transaction.valid?
    expect(duplicate_transaction.errors[:monzo_id])
      .to include('has already been taken')
  end

  # Temporary - Transaction creation will be moved to a service/helper,
  # especially with regards to transmuting requests into Transactions.
  it 'has all given info when created via seeding' do
    VCR.use_cassette('monzo_transaction') do
      seed_transaction(transaction)
      has_nil = Transaction
                .last
                .attributes
                .except('updated_at', 'id', 'created_at', 'decline_reason')
                .value?(nil)
      expect(has_nil).to be false
    end
  end

  def initialize_mondo_client
    Mondo::Client.new(
      token: ENV['MONDO_TOKEN'],
      account_id: ENV['ACCOUNT_ID']
    )
  end

  def seed_transaction(transaction)
    merchant = transaction.merchant
    unless merchant.nil?
      internal_merchant = Merchant.create(
        name: merchant.name,
        logo: merchant.logo,
        monzo_id: merchant.id,
        group_id: merchant.group_id,
        created: merchant.created,
        address: merchant.address
      )
    end
    Transaction.create(
      amount: transaction.amount,
      created: transaction.created,
      currency: transaction.currency,
      description: transaction.description,
      merchant_id: internal_merchant&.id,
      notes: transaction.notes,
      is_load: transaction.is_load,
      settled: transaction.settled,
      category_id: Category.find_or_create_by(name: transaction.category).id,
      monzo_id: transaction.id
    )
  end
end
