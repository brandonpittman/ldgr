# Ldgr

Ldgr is a command-line tool for adding, sorting and tagging transactions in your Ledger file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ldgr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ldgr

## Usage

Type `ldgr -h` at the command-line to see available commands and options.

## CLI
```sh
ldgr add --payee Brandon \
         --amount 1000 \
         --account Something \
         --equity Cash \
         --date 2017-02-01 \
         --effective 2017-02-03 \
         --cleared`
ldgr clear
ldgr sort
```

## Library

~~~ruby
transaction = Ldgr::Transaction.new do |t|
    t.payee = 'Brandon'
    t.amount = 1000
    t.account = 'Something'
    t.equity = 'Cash
    t.date = Date.today + 1'
    t.effective = Date.today + 10'
    t.cleared = true
end
~~~

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/brandonpittman/ldgr. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

