# frozen_string_literal: true
require 'test_helper'

describe Ldgr do
  it 'must have a version number' do
     expect(::Ldgr::VERSION).wont_be_nil
  end
end
