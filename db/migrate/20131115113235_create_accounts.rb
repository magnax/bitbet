class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :user_id
      t.string :nr
      t.string :type

      t.timestamps
    end
  end
end
