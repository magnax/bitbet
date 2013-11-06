class CreateBets < ActiveRecord::Migration
  def change
    create_table :bets do |t|
      t.integer :user_id
      t.string :name
      t.text :text
      t.integer :category_id
      t.date :event_at
      t.date :deadline
      t.datetime :closed_at
      t.string :status
      t.boolean :positive

      t.timestamps
    end
  end
end
