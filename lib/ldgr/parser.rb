require 'csv'
require 'date'
require 'highline/import'
require 'optparse'
require 'optparse/date'
require 'pathname'
require 'strscan'
require 'fileutils'

module Ldgr
  class Parser
    FILEBASE = Dir.home + '/.config/ledger/'
    FILE = FILEBASE + 'transactions.dat'
    VERSION = Ldgr::VERSION                                                                                                   # ~> NameError: uninitialized constant Ldgr::VERSION
    PROGRAM_NAME = 'ldgr'
    MATCH = /(?=(\n\d\d\d\d-\d\d-\d\d)(=\d\d\d\d-\d\d-\d\d)*)|\z/
    OTHER_MATCH = /(?=(\d\d\d\d-\d\d-\d\d)(=\d\d\d\d-\d\d-\d\d)*)/
    DEFAULT_CURRENCY = Pathname(FILEBASE + '/default_currency').exist? ? Pathname(FILEBASE + '/default_currency').read.chomp : '$'

    def self.parse
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

      config = {}
      command = String(cli.parse(ARGV, into: config)[0]).to_sym

      send(command, config) if methods.include? command
    end

    def self.add(config)
      error_policy = ->(key) { fail "You need to provide a value for #{key.to_s}." }

      transaction = Transaction.new do |t|
        date = String(config.fetch(:date) { Date.today } )
        effective = String(config.fetch(:effective) { Date.today })

        t.payee    = config.fetch(:payee) { |key| error_policy.call(key) }
        t.account  = config.fetch(:account) { |key| error_policy.call(key) }
        t.amount   = config.fetch(:amount) { |key| error_policy.call(key) }
        t.currency = config.fetch(:currency) { DEFAULT_CURRENCY }
        t.equity   = config.fetch(:equity) { "Cash" }
        t.cleared  = config[:cleared] ? '* ' : ''
        t.date     = date == effective ? date : date << '=' << effective
      end

      File.open(FILE, 'a') { |file| file.puts transaction }
    end

    def self.clear(config)
      output = ''
      pattern = /((^\d{,4}-\d{,2}-\d{,2})(=\d{,4}-\d{,2}-\d{,2})?) ([^\*]+)/
      count = 0

      File.open(FILE, 'r') do |transactions|
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
            puts "\n#{HighLine.color(transaction, :magenta)}"
            question = ask('Do you want to clear this?  ') do |q|
              q.default = 'No'
            end
            transaction.gsub!(pattern, "#{front} * #{back}") if question =~ /y/i
          end
          output << transaction
        end
      end
      IO.write(FILE, output)
    end

    def self.tag(config)
      output = ''
      pattern = /(^\s+Expenses[^:])\s*(¥.+)/
      count = 0
      previous = ''

      File.open(FILE, 'r') do |transactions|
        transactions.each_line do |transaction|
          match = pattern.match(transaction)
          if match
            count += 1
            puts "\n#{HighLine.color(previous, :blue)} #{HighLine.color(match[2], :red)}"
            question = ask('What account does this belong to?  ') { |q| q.default = 'None' }
            transaction.gsub!(match[1], "  #{question.capitalize}  ") if question != 'None'
          end
          previous = transaction.chomp
          output << transaction
        end
      end
      IO.write(FILE, output)
    end

    def self.sort(config)
      text = File.read(FILE).gsub(/\n+|\r+/, "\n").squeeze("\n").strip
      scanner = StringScanner.new(text)
      results = []

      until scanner.eos?
        results << scanner.scan_until(MATCH)
        scanner.skip_until(OTHER_MATCH)
      end

      File.open(FILE, 'w') do |file|
        file.puts results.sort
      end
    end

    def self.open(_)
      def self.open_file(file_to_open)
        checked_file = "#{FILEBASE}#{file_to_open}.dat"
        raise "#{checked_file} doesn't exist." unless Pathname(checked_file).exist?
        system(ENV['EDITOR'], checked_file)
      end

      open_file(ARGV[1])
    end

    def self.setup
      unless config_exist?
        %w(transactions.dat accounts.dat budgets.dat aliases.dat commodities.dat setup.dat ledger.dat).each do |file|
          FileUtils.touch("#{FILEBASE}#{file}")
        end
      end
    end

    def self.config_exist?
      return false unless Pathname(FILEBASE).exist?
      true
    end

    setup
  end
end
