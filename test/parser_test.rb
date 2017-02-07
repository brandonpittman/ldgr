require 'test_helper'
require 'yaml'
require 'tempfile'

describe Ldgr::Parser do
  let(:yaml) { {currency: '$'} } 
  let(:ldgr_defaults) { Ldgr::Parser::LDGR_DEFAULTS }
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
    expect(Ldgr::Parser.defaults(config_file)).must_equal merged_defaults
    expect(YAML.load_file(config_file).fetch(:currency)).must_equal '$'
  end

  it 'can write a transaction to a transactions file' do
    transactions_file = Tempfile.new('transactions.dat')
    Ldgr::Parser.add(ldgr_defaults.merge(non_defaults), transactions_file)
    expect(transactions_file.read).must_equal oxo_transaction
  end
end
