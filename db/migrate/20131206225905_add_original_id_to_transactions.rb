class AddOriginalIdToTransactions < ActiveRecord::Migration
  def up
    add_column :transactions, :original_id, :integer
  end

  def down
    remove_column :transactions, :original_id, :integer
  end
end
