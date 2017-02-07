require 'test_helper'
require 'yaml'
require 'tempfile'

describe Ldgr::Parser do
  let(:yaml) { {currency: '$'} } 
  let(:ldgr_defaults) { Ldgr::Parser::LDGR_DEFAULTS }
  let(:merged_defaults) { ldgr_defaults.merge(yaml) }

  it 'can read config files' do
    config_file = Tempfile.new('ldgr.yaml')
    config_file.write(ldgr_defaults.merge(yaml).to_yaml)
    config_file.rewind
    expect(Ldgr::Parser.defaults(config_file)).must_equal merged_defaults
    expect(YAML.load_file(config_file).fetch(:currency)).must_equal '$'
  end
end
