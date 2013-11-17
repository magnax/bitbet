class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.integer :user_id
      t.integer :amount
      t.integer :account_id
      t.integer :bet_id
      t.string :type
      t.string :txid
      t.integer :time
      t.integer :timereceived

      t.timestamps
    end
  end
end
