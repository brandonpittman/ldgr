require 'test_helper'  # ~> LoadError: cannot load such file -- test_helper
require 'yaml'
require 'tempfile'

describe Ldgr::Parser do
  let(:parser) { Ldgr::Parser.new }
  let(:yaml) { {currency: '$'} } 
  let(:ldgr_defaults) { parser.defaults }
  let(:merged_defaults) { ldgr_defaults.merge(yaml) }
  let(:today) { Date.today }
  let(:non_defaults) { {payee: 'OXO', account: 'Alcohol', amount: '2000', currency: '¥'} }
  let(:oxo_transaction) {
    <<~HERE
    #{today} OXO
      Alcohol  ¥2000
      Cash
    HERE
  }

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

# ~> LoadError
# ~> cannot load such file -- test_helper
# ~>
# ~> /Users/brandonpittman/.rubies/ruby-2.4.0/lib/ruby/site_ruby/2.4.0/rubygems/core_ext/kernel_require.rb:55:in `require'
# ~> /Users/brandonpittman/.rubies/ruby-2.4.0/lib/ruby/site_ruby/2.4.0/rubygems/core_ext/kernel_require.rb:55:in `require'
# ~> /var/folders/q5/p4rpcgvx101ctdyg2xb6wtv40000gn/T/seeing_is_believing_temp_dir20170209-95865-9z8n5b/program.rb:1:in `<main>'
