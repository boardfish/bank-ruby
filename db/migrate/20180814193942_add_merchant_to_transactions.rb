# frozen_string_literal: true

class AddMerchantToTransactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :merchant
    add_reference :transactions, :merchant, foreign_key: true
  end
end
