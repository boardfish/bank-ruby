# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe TransactionsController, type: :request do
  it 'passes all info during monzo_webhook_add' do
    headers = { CONTENT_TYPE: 'application/json', ACCEPT: 'application/json' }
    post '/monzo_webhook_add',
         params: file_fixture('sample_webhook_input.json').read,
         headers: headers
    created_transaction = Transaction.last
    expected_transaction = Transaction.new(
      amount: -3.5,
      created: '2015-09-04T14:28:40Z',
      currency: 'GBP',
      description: 'Ozone Coffee Roasters',
      monzo_id: 'tx_00008zjky19HyFLAzlUk7t',
      is_load: false,
      settled: true,
      category_id: Transaction.last.category_id,
      merchant_id: Transaction.last.merchant_id
    )
    expected_transaction.save
    comparison_array = [expected_transaction, created_transaction]
                       .map { |t| filter_attributes(t) }
    expect(comparison_array.uniq.length).to eq(1)
  end

  def filter_attributes(transaction)
    transaction.attributes.except(
      'updated_at',
      'id',
      'created_at',
      'category_id'
    )
  end
end
# rubocop:enable Metrics/BlockLength
