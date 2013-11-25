class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.integer :amount, limit: 8
      t.integer :bet_id

      t.timestamps
    end
  end
end
