class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      t.string :fullccnum, :null => false
      t.string :name
      t.integer :amount
      t.string :order
      t.string :auth_result
      t.timestamp :settled_at
      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
