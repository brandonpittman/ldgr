require 'test_helper'

describe 'Private methods---Delete if they fail' do
  let(:parser) { Ldgr::Parser.new }
  let(:yaml) { { currency: '$' } }
  let(:ldgr_defaults) { parser.send(:defaults) }
  let(:merged_defaults) { ldgr_defaults.merge(yaml) }

  it 'can read config files' do
    config_file = Tempfile.new('ldgr.yaml')
    config_file.write(ldgr_defaults.merge(yaml).to_yaml)
    config_file.rewind
    expect(YAML.load_file(config_file).fetch(:currency)).must_equal '$'
  end
end
