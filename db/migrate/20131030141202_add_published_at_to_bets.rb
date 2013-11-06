class AddPublishedAtToBets < ActiveRecord::Migration
  def change
  	add_column :bets, :published_at, :datetime, before: :closed_at
  end
end
