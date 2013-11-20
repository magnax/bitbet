class RenameTypeInOperationsTable < ActiveRecord::Migration
  def change
	rename_column :operations, :type, :operation_type
  end
end
