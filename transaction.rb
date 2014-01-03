require 'active_record'

class Transaction < ActiveRecord::Base
  after_create do |transaction|
    if transaction.id % 10 == 0 && (record_count = Transaction.count) > 7000
      Transaction.delete_all
    end
  end
end
