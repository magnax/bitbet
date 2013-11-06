class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :user_id
      t.integer :bet_id
      t.integer :amount
      t.boolean :positive

      t.timestamps
    end
  end
end
