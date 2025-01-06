class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :salesperson, null: false, foreign_key: { to_table: :users }
      t.float :value
      t.string :gateway_used
      t.references :customer, null: false, foreign_key: true
      t.float :commission_percentage_on_sale
      t.float :commission_value
      t.string :status

      t.timestamps
    end
  end
end
