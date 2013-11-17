class UsersAddRefId < ActiveRecord::Migration
  def change
  	add_column :users, :ref_id, :integer
  end
end
