require 'test_helper'

class LdgrTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Ldgr::VERSION
  end

  def test_new_transaction_is_created
    assert_equal Ldgr::Transaction, Ldgr::Transaction.new.class
  end
end
