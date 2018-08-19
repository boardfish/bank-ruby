# frozen_string_literal: true

class RemoveMonzoCategoryFromTransactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :monzo_category
  end
end
