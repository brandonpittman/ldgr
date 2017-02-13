# frozen_string_literal: true
require 'test_helper'

describe Ldgr::Transaction do
  let(:yen)    { '¥' }
  let(:dollar) { '$' }
  let(:date)   { Date.today}

  let(:transaction) do
    Ldgr::Transaction.new do |t|
      t.payee = 'Brandon'
      t.account = 'Entertainment'
      t.amount = '1000'
      t.date = date
      t.effective = date
      t.currency = yen
      t.cleared = true
    end
  end

  it 'validates transactions' do
    assert transaction.valid?

    transaction.amount = ''
    refute transaction.valid?

    transaction.amount = nil
    refute transaction.valid?
  end

  it 'can change currency from default' do
    assert_equal yen, transaction.currency
    transaction.currency = dollar
    assert_equal dollar, transaction.currency
    assert transaction.valid?
  end
end
