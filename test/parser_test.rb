# frozen_string_literal: true
require 'test_helper'
require 'yaml'
require 'tempfile'
require 'irb'

describe Ldgr::Parser do
  let(:parser) { Ldgr::Parser.new }
  let(:yaml) { { currency: '$' } }
  let(:ldgr_defaults) { parser.defaults }
  let(:merged_defaults) { ldgr_defaults.merge(yaml) }
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

  it 'can read config files' do
    config_file = Tempfile.new('ldgr.yaml')
    config_file.write(ldgr_defaults.merge(yaml).to_yaml)
    config_file.rewind
    expect(YAML.load_file(config_file).fetch(:currency)).must_equal '$'
  end

  it 'can write a transaction to a transactions file' do
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
  end

  it 'requires amount on add' do
    transactions_file = Tempfile.new('transactions.dat')
    parser = Ldgr::Parser.new(config: non_defaults)
    parser.config.delete(:amount)
    parser.transactions_file = transactions_file
    add_call = proc { parser.add }
    expect(add_call).must_raise(RuntimeError)
  end

  it 'requires payee on add' do
    transactions_file = Tempfile.new('transactions.dat')
    parser = Ldgr::Parser.new(config: non_defaults)
    parser.config.delete(:payee)
    parser.transactions_file = transactions_file
    add_call = proc { parser.add }
    expect(add_call).must_raise(RuntimeError)
  end
end
