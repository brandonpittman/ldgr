module Ldgr
  # Builds a transaction
  #
  # Examples
  #
  #   Transaction.new do |t|
  #     t.payee = "Something"
  #     t.amount = 1000
  #     t.date = Date.today + 1
  #   end
  #   # => <class Transaction @payee="Something", @amount=1000, @date=Date.today + 1>
  #
  # Returns a transaction.
  class Transaction
    attr_accessor :payee, :amount, :account, :equity, :date, :effective, :currency, :cleared

    def initialize(&block)
      yield self if block_given?
    end

    def to_s
      <<~HERE
      #{date} #{cleared}#{payee}
        #{account}  #{currency}#{amount}
        #{equity}
      HERE
    end

    def valid?
      return false if String(payee).empty?
      return false if String(amount).empty?
      return false if String(account).empty?
      true
    end
  end
end
