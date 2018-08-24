# frozen_string_literal: true

# TransactionsService: manages sorting and filtering transactions into and out
# of the system.
module TransactionsService
  class << self
  def group_by_month(transactions)
    transactions
      .group_by { |t| t.created.beginning_of_month }
      .map { |k, v| { k.strftime('%m/%Y') => v } }
      .reduce(:merge)
  end

  def group_by_category(transactions)
    transactions
      .group_by(&:category_id)
      .map { |c, t| { c => group_by_month(t) } }
      .reduce(:merge)
  end

  def transactions_by_category
    group_by_category(Transaction.all)
  end

  def transactions_by_month
    group_by_month(Transaction.all)
  end

  def totals_by_category(transactions)
    transactions.group_by(&:category_id)
                .map do |k, v|
      { Category.find_by_id(k) => v.map { |t| t['amount'] }
                                   .reduce(0, :+) }
    end .reduce(:merge)
  end

  def totals_by_month
    cumulative_total = 0.0
    totals_by_month = transactions_by_month.values.map do |transactions|
      transactions.map(&:amount).reduce(0, :+)
    end
    totals_by_month.map { |sum| cumulative_total += sum }
  end

  def totals_by_month_by_category
    transactions_by_category.map do |cid, t_b_m|
      { cid => t_b_m.map do |m, ts|
        { m => ts.map(&:amount).reduce(0, :+) }
      end.reduce(:merge) }
    end.reduce(:merge)
  end

  def monzo_request_reformat(request)
    request_body = JSON.parse(request.body.read)
    return unless request_body['type'] == 'transaction.created'
    source = request_body['data']
    merchant = source['merchant']
    internal_merchant = monzo_request_to_merchant(merchant)
    @transaction = monzo_request_to_transaction(source, internal_merchant)
  end

  # rubocop:disable Metrics/MethodLength
  def monzo_request_to_transaction(source, internal_merchant)
    Transaction.create(
      amount: source['amount'] / 100.0,
      created: source['created'],
      currency: source['currency'],
      description: source['description'],
      merchant_id: internal_merchant&.id,
      notes: source['notes'],
      is_load: source['is_load'],
      settled: source['settled'],
      category_id: Category.find_or_create_by(name: source['category']),
      monzo_id: source['id']
    )
  end
  # rubocop:enable Metrics/MethodLength

  def monzo_request_to_merchant(source)
    return if source.nil?
    Merchant.where(monzo_id: source['id']).first_or_create do |merchant|
      merchant.name = source['name']
      merchant.logo = source['logo']
      merchant.monzo_id = source['id']
      merchant.group_id = source['group_id']
      merchant.created = source['created']
      merchant.address = source['address']
    end
  end
  end
end
