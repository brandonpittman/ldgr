require 'ldgr/version'      # => true
require 'ldgr/transaction'  # ~> LoadError: cannot load such file -- ldgr/transaction
require 'ldgr/parser'

module Ldgr
  puts 'hi'
end

# ~> LoadError
# ~> cannot load such file -- ldgr/transaction
# ~>
# ~> /Users/brandonpittman/.rubies/ruby-2.4.0/lib/ruby/site_ruby/2.4.0/rubygems/core_ext/kernel_require.rb:55:in `require'
# ~> /Users/brandonpittman/.rubies/ruby-2.4.0/lib/ruby/site_ruby/2.4.0/rubygems/core_ext/kernel_require.rb:55:in `require'
# ~> /var/folders/q5/p4rpcgvx101ctdyg2xb6wtv40000gn/T/seeing_is_believing_temp_dir20170203-47975-1dy1rf8/program.rb:2:in `<main>'
