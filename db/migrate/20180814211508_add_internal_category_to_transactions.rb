class AddInternalCategoryToTransactions < ActiveRecord::Migration[5.2]
  def change
    rename_column :transactions, :category, :monzo_category
    add_reference :transactions, :category, foreign_key: true
  end
end
