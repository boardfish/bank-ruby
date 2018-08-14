class CreateMerchants < ActiveRecord::Migration[5.2]
  def change
    create_table :merchants do |t|
      t.string :name
      t.string :logo
      t.string :address
      t.string :monzo_id
      t.string :group_id
      t.datetime :created

      t.timestamps
    end
  end
end
