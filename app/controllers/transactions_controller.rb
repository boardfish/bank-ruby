# frozen_string_literal: true

require 'json'

class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[show edit update destroy]
  protect_from_forgery except: [:monzo_webhook_add]

  # GET /transactions
  # GET /transactions.json
  STARTING_BALANCE = 304.15

  def index
    @transactions = transactions_by_month
    @index = params[:months_back].to_i || 0
    @month = @transactions.keys.reverse[@index]
    @transactions = @transactions[@month].reverse
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
    @totals = @transactions_by_month.map { |_month, transactions|
      transactions.map(&:amount).reduce(0, :+)
    }.map{ |sum| cumulative_total += sum }
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
    unless merchant.nil?
      internal_merchant = Merchant.create(
        name: merchant['name'],
        logo: merchant['logo'],
        monzo_id: merchant['id'],
        group_id: merchant['group_id'],
        created: merchant['created'],
        address: merchant['address']
      )
    end
    @transaction = Transaction.create(
      amount: source['amount'],
      created: source['created'],
      currency: source['currency'],
      description: source['description'],
      merchant_id: internal_merchant&.id,
      notes: source['notes'],
      is_load: source['is_load'],
      settled: source['settled'],
      monzo_category: internal_merchant&.category,
      category_id: nil
    )

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, notice: 'Transaction was successfully created.' }
        format.json { render :show, status: :created, location: @transaction }
      else
        format.html { render :new }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transactions/1
  # PATCH/PUT /transactions/1.json
  def update
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to transactions_path, notice: 'Transaction was successfully updated.' }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render transactions_path, notice: 'Couldn\'t update transaction.' }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url, notice: 'Transaction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_transaction
    @transaction = Transaction.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def transaction_params
    params.require(:transaction).permit(:category_id)
  end
end
