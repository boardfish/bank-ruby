# frozen_string_literal: true

require 'json'

# TransactionsController - Allows the user to see their transactions by month
# or in a summary
class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[show edit update destroy]
  protect_from_forgery except: [:monzo_webhook_add]

  # GET /transactions
  # GET /transactions.json
  STARTING_BALANCE = ENV['STARTING_BALANCE'].to_f

  def index
    @all_transactions = transactions_by_month
    @index = params[:months_back]
             .to_i
             .clamp(0, @all_transactions.keys.length - 1) || 0
    @month = @all_transactions.keys.reverse[@index]
    @transactions = @all_transactions[@month].reverse
    @summary = @transactions.group_by(&:category_id)
                            .map do |k, v|
      { Category.find_by_id(k) => v.map { |t| t['amount'] }
                                   .reduce(0, :+) }
    end .reduce(:merge)
    @balance = Transaction.sum(:amount) + STARTING_BALANCE
  end

  def summary
    @transactions_by_month = transactions_by_month
    @summary = transactions_by_category.map do |cid, t_b_m|
      { cid => t_b_m.map do |m, ts|
        { m => ts.map(&:amount).reduce(0, :+) }
      end.reduce(:merge) }
    end.reduce(:merge)
    cumulative_total = STARTING_BALANCE
    @totals = @transactions_by_month.map do |_month, transactions|
      transactions.map(&:amount).reduce(0, :+)
    end
    @totals = @totals.map { |sum| cumulative_total += sum }
  end

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

  def transactions_by_month
    group_by_month(Transaction.all)
  end

  def transactions_by_category
    group_by_category(Transaction.all)
  end

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

  # GET /transactions/1
  # GET /transactions/1.json
  def show; end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit; end

  # POST /transactions
  # POST /transactions.json
  def monzo_webhook_add
    request_body = JSON.parse(request.body.read)
    return unless request_body['type'] == 'transaction.created'
    source = request_body['data']
    merchant = source['merchant']
    internal_merchant = monzo_request_to_merchant(merchant)
    @transaction = monzo_request_to_transaction(source, internal_merchant)

    respond_to do |format|
      if @transaction.save
        format.html do
          redirect_to @transaction,
                      notice: 'Transaction was successfully created.'
        end
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new }
        format.json do
          render json: @transaction.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html do
          redirect_to transactions_path,
                      notice: 'Transaction was successfully updated.'
        end
        format.json { render :show, status: :ok, location: @transaction }
        format.js
      else
        format.html  render transactions_path,
                            notice: 'Couldn\'t update transaction.'
        format.json  render json: @transaction.errors,
                            status: :unprocessable_entity
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
    respond_to do |format|
      format.html do
        redirect_to transactions_url,
                    notice: 'Transaction was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list
  # through.
  def transaction_params
    params.require(:transaction).permit(:category_id)
  end
end
