class AddBannedToBets < ActiveRecord::Migration
  def change
  	add_column :bets, :banned, :boolean, default: 0
  end
end
