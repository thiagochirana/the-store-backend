class CreateCommissions < ActiveRecord::Migration[8.0]
  def change
    create_table :commissions do |t|
      t.references :user, null: false, foreign_key: true
      t.float :percentage, default: 0.0

      t.timestamps
    end
  end
end
