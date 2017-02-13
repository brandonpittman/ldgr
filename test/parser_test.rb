# frozen_string_literal: true
require 'test_helper'
require 'yaml'
require 'tempfile'
require 'irb'

describe Ldgr::Parser do
  let(:parser) { Ldgr::Parser.new }
  let(:yaml) { { currency: '$' } }
  let(:today) { Date.today }
  let(:non_defaults) do
    { payee: 'OXO', account: 'Alcohol', amount: '2000', currency: '¥' }
  end
  let(:oxo_transaction) do
    <<~HERE
    #{today} OXO
      Alcohol  ¥2000
      Cash
    HERE
  end


  it 'can add a transaction' do
    transactions_file = Tempfile.new('transactions.dat')
    parser = Ldgr::Parser.new(config: non_defaults)
    parser.transactions_file = transactions_file
    parser.add
    expect(transactions_file.read).must_equal oxo_transaction
  end

  it 'requires account on add' do
    transactions_file = Tempfile.new('transactions.dat')
    parser = Ldgr::Parser.new(config: non_defaults)
    parser.config.delete(:account)
    parser.transactions_file = transactions_file
    add_call = proc { parser.add }
    expect(add_call).must_raise(RuntimeError)
    parser.config.delete(:amount)
    add_call = proc { parser.add }
    expect(add_call).must_raise(RuntimeError)
    parser.config.delete(:payee)
    add_call = proc { parser.add }
    expect(add_call).must_raise(RuntimeError)
  end

  it 'sorts transactions' do
    skip 'not yet implemented'
  end

  it 'tags untagged transactions' do
    skip 'not yet implemented'
  end

  it 'clears uncleared transactions' do
    skip 'not yet implemented'
  end
end
