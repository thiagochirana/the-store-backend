class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :role, default: :salesperson
      t.string :email, null: false
      t.string :password_digest, null: false

      t.references :shopowner, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
