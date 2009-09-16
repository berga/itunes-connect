require "appstore/rc_file"
require "appstore/store"

module AppStore::Commands
  class Report                  # :nodoc:
    def initialize(c, rcfile=AppStore::RcFile.default)
      c.opt('b', 'db', :desc => 'Dump report to sqlite DB at the given path')
      c.opt('c', 'country',
            :desc => 'A two-letter country code to filter results with')
      c.opt('f', 'from', :desc => 'The starting date, inclusive') do |f|
        Date.parse(f)
      end
      c.opt('t', 'to', :desc => 'The ending date, inclusive') do |t|
        Date.parse(t)
      end
      c.flag('s', 'summarize', :desc => 'Summarize results by country code')
      c.flag('n', 'no-header', :desc => 'Suppress the column headers on output')
      c.opt('d', 'delimiter',
             :desc => 'The delimiter to use for output (normally TAB)',
             :default => "\t")
      @rcfile = rcfile
    end

    def execute!(opts, args=[], out=$stdout)
      db = opts.db || @rcfile.database || nil
      raise ArgumentError.new("Missing :db option") if db.nil?
      store = AppStore::Store.new(db)
      params = {
        :to => opts.to,
        :from => opts.from,
        :country => opts.country
      }

      if opts.group?
        unless opts.no_header?
          out.puts(%w(Country Installs Upgrades).join(opts.delimiter))
        end
        store.country_counts(params).each do |x|
          out.puts [x.country,
                    x.install_count,
                    x.update_count].join(opts.delimiter)
        end
      else
        unless opts.no_header?
          out.puts(%w(Date Country Installs Upgrades).join(opts.delimiter))
        end
        store.counts(params).each do |x|
          out.puts [x.report_date,
                    x.country,
                    x.install_count,
                    x.update_count].join(opts.delimiter)
        end
      end
      out.flush
    end

    def description
      "Generates reports from a local database"
    end
  end
end
