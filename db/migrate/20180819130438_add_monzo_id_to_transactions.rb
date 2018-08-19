class AddMonzoIdToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :monzo_id, :string
  end
end
