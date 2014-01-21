class AddRefundedAtToTransactions < ActiveRecord::Migration
  def up
    add_column :transactions, :refunded_at, :datetime
  end

  def down
    remove_column :transactions, :refunded_at, :datetime
  end
end
