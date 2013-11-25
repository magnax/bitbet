class AddNotesToFees < ActiveRecord::Migration
  def change
    add_column :fees, :notes, :string
  end
end
