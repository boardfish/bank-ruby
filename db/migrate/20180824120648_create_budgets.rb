class CreateBudgets < ActiveRecord::Migration[5.2]
  def change
    create_table :budgets do |t|
      t.references :category, foreign_key: true
      t.datetime :month
      t.decimal :amount

      t.timestamps
    end
  end
end
