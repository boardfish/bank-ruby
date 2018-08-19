# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.decimal :amount
      t.string :decline_reason
      t.boolean :is_load
      t.datetime :settled
      t.string :category
      t.string :merchant
      t.datetime :created
      t.string :currency
      t.string :description
      t.string :notes

      t.timestamps
    end
  end
end
