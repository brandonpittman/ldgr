require 'test_helper'  # ~> LoadError: cannot load such file -- test_helper

class LdgrTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Ldgr::VERSION
  end

  def test_it_does_something_useful
    assert false
  end

  def test_new_transaction_is_created
    assert_equal Transaction, Transaction.new.class
  end
end

# ~> LoadError
# ~> cannot load such file -- test_helper
# ~>
# ~> /Users/brandonpittman/.rubies/ruby-2.4.0/lib/ruby/site_ruby/2.4.0/rubygems/core_ext/kernel_require.rb:55:in `require'
# ~> /Users/brandonpittman/.rubies/ruby-2.4.0/lib/ruby/site_ruby/2.4.0/rubygems/core_ext/kernel_require.rb:55:in `require'
# ~> /var/folders/q5/p4rpcgvx101ctdyg2xb6wtv40000gn/T/seeing_is_believing_temp_dir20170203-46468-wa5tvg/program.rb:1:in `<main>'
