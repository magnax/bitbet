class AddBannedToBets < ActiveRecord::Migration
  def change
  	add_column :bets, :banned, :boolean, default: false
  end
end
