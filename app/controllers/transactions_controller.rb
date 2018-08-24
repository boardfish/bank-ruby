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
    @all_transactions = TransactionsService.transactions_by_month
    @index = params[:months_back]
             .to_i
             .clamp(0, @all_transactions.keys.length - 1) || 0
    @month = @all_transactions.keys.reverse[@index]
    @transactions = @all_transactions[@month].reverse
    @summary = TransactionsService.totals_by_category(@transactions)
    @balance = Transaction.sum(:amount) + STARTING_BALANCE
  end

  def summary
    @transactions_by_month = TransactionsService.transactions_by_month
    @summary = TransactionsService.totals_by_month_by_category
    cumulative_total = STARTING_BALANCE
    @totals = TransactionsService.totals_by_month
    @totals = @totals.map { |sum| cumulative_total += sum }
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
    @transaction = TransactionsService.monzo_request_reformat(request)

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
        format.html redirect_to transactions_path,
                                notice: 'Transaction was successfully updated.'
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
