# frozen_string_literal: false
require 'irb'
require 'csv'
require 'date'
require 'optparse'
require 'optparse/date'
require 'pathname'
require 'strscan'
require 'fileutils'
require 'yaml'

module Ldgr
  # Parses configuration options.
  #
  #
  # Examples
  #
  #   Ldgr::Parser.parse
  #   # => some file action
  #
  # Returns nothing on success.
  class Parser
    FILEBASE = Dir.home + '/.config/ledger/'
    VERSION = Ldgr::VERSION
    PROGRAM_NAME = 'ldgr'
    MATCH = /(?=(\n\d\d\d\d-\d\d-\d\d)(=\d\d\d\d-\d\d-\d\d)*)|\z/
    OTHER_MATCH = /(?=(\d\d\d\d-\d\d-\d\d)(=\d\d\d\d-\d\d-\d\d)*)/
    COMMANDS = %w(add sort tag clear open).freeze

    attr_accessor :transactions_file, :config

    # Public: Creates a new Parser object
    #
    # config  - A hash of config options
    #
    # Examples
    #
    #   new(config: {currency: '¥'})
    #   # => <ParserObject>
    #
    # Returns a Parser object.
    def initialize(config: {})
      @transactions_file = defaults.fetch(:transactions_file)
      @config = defaults.merge(user_config).merge(config)
    end

    # Public: Kicks off the CLI
    #
    # Examples
    #
    #   parse
    #
    # Returns nothing.
    def parse
      setup

      cli = OptionParser.new do |o|
        o.banner = "Usage #{PROGRAM_NAME} [add|sort|tag|clear|open]"
        o.program_name = PROGRAM_NAME
        o.version = VERSION

        o.define '-C', '--currency=CURRENCY', String, 'the currency of the transaction'
        o.define '-E', '--effective=EFFECTIVE_DATE', Date, 'the effective date of the transaction'
        o.define '-a', '--account=ACCOUNT', String, 'the account of the transaction'
        o.define '-c', '--cleared', TrueClass, 'clear the transaction'
        o.define '-d', '--date=DATE', Date, 'the date of the transaction'
        o.define '-e', '--equity=EQUITY', String, 'the equity of the transaction'
        o.define '-f', '--file=FILE', String, 'a file of transactions'
        o.define '-A', '--amount=AMOUNT', String, 'the amount of the transaction'
        o.define '-p', '--payee=PAYEE', String, 'the payee of the transaction'
      end

      command = String(cli.parse(ARGV, into: config)[0])
      send(command) if COMMANDS.include? command
    end

    # Public: Adds a transaction to the transactions_file.
    #
    # Examples
    #
    #   add
    #
    # Returns nothing.
    def add
      error_policy = ->(key) { fail "You need to provide a value for #{key.to_s}." }

      transaction = Transaction.new do |t|
        date = String(config.fetch(:date) { |key| error_policy.call(key) })
        effective = String(config.fetch(:effective) { |key| error_policy.call(key) })

        t.payee    = config.fetch(:payee) { |key| error_policy.call(key) }
        t.account  = config.fetch(:account) { |key| error_policy.call(key) }
        t.amount   = config.fetch(:amount) { |key| error_policy.call(key) }
        t.currency = config.fetch(:currency) { config.fetch(:currency) }
        t.equity   = config.fetch(:equity) { config.fetch(:equity) }
        t.cleared  = config[:cleared] ? '* ' : ''
        t.date     = date == effective ? date : date << '=' << effective
      end

      File.open(transactions_file, 'a') { |file| file.puts transaction }
    end

    # Public: Runs through all uncleared transactions that are passed
    # their effective date and offers to clear them.
    #
    # Examples
    #
    #   clear
    #
    # Returns nothing.
    def clear
      output = ''
      pattern = /((^\d{,4}-\d{,2}-\d{,2})(=\d{,4}-\d{,2}-\d{,2})?) ([^\*]+)/
      count = 0

      File.open(transactions_file, 'r') do |transactions|
        transactions.each_line do |transaction|
          match = pattern.match(transaction)
          if match && match[3]
            effective_date = Date.parse(match[3])
          else
            effective_date = Date.today
          end
          if match && Date.today >= effective_date
            count += 1
            front = match[1]
            back = match[4]
            puts transaction
            question = ask('Do you want to clear this?  ') do |q|
              q.default = 'No'
            end
            transaction.gsub!(pattern, "#{front} * #{back}") if question.match?(/y/i)
          end
          output << transaction
        end
      end
      IO.write(transactions_file, output)
    end

    # Public: Runs through all transactions with only Expenses set as the account and lets you enter an account name.
    #
    # Examples
    #
    #   tag
    #
    # Returns nothing.
    def tag
      output = ''
      pattern = /(^\s+Expenses[^:])\s*(¥.+)/
      count = 0
      previous = ''

      File.open(transactions_file, 'r') do |transactions|
        transactions.each_line do |transaction|
          match = pattern.match(transaction)
          if match
            count += 1
            puts "\n#{previous} #{match[2]}"
            question = ask('What account does this belong to?  ') { |q| q.default = 'None' }
            transaction.gsub!(match[1], "  #{question.capitalize}  ") if question != 'None'
          end
          previous = transaction.chomp
          output << transaction
        end
      end
      IO.write(transactions_file, output)
    end

    # Public: Sorts all transactions by date.
    #
    # Examples
    #
    #   sort
    #
    # Returns nothing.
    def sort
      text = File.read(transactions_file).gsub(/\n+|\r+/, "\n").squeeze("\n").strip
      scanner = StringScanner.new(text)
      results = []

      until scanner.eos?
        results << scanner.scan_until(MATCH)
        scanner.skip_until(OTHER_MATCH)
      end

      File.open(transactions_file, 'w') do |file|
        file.puts results.sort
      end
    end

    private
    # Private: User-specified config options
    #
    # Examples
    #
    #   user_config
    #   # => {all the config options from the user's YAML file}
    #
    # Returns a hash of user-specified config options.
    def user_config
      path = Pathname(FILEBASE + 'ldgr.yaml')
      path.exist? ? YAML.load_file(path).to_h : {}
    end

    # Private: Opens a settings file from ~/.config/ledger
    #
    # Examples
    #
    #   open accounts
    #   # => accounts file opens in $EDITOR
    #
    # Returns nothing.
    def open
      def open_file(file_to_open)
        checked_file = "#{FILEBASE}#{file_to_open}.dat"
        fail "#{checked_file} doesn't exist." unless Pathname(checked_file).exist?
        system(ENV['EDITOR'], checked_file)
      end

      open_file(ARGV[1])
    end

    # Private: ldgr's default configuration options
    #
    # Examples
    #
    #   defaults
    #   # => {all the configuration options}
    #
    # Returns a hash of default configuration options.
    def defaults
      {
        currency: '$',
        equity: 'Cash',
        effective: Date.today,
        date: Date.today,
        cleared: false,
        transactions_file: FILEBASE + 'transactions.dat'
      }
    end

    # Private: Prepares users' file system for ldgr.
    #
    # Returns nothing.
    def setup
      setup_files = %w(transactions.dat accounts.dat budgets.dat aliases.dat commodities.dat setup.dat ledger.dat ldgr.yaml)
      FileUtils.mkdir_p(FILEBASE)
      setup_files.each do |file|
        FileUtils.touch("#{FILEBASE}#{file}")
      end
    end
  end
end
