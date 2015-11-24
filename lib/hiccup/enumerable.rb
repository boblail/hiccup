require "hiccup/core_ext/date"
require "hiccup/enumerable/annually_enumerator"
require "hiccup/enumerable/monthly_enumerator"
require "hiccup/enumerable/never_enumerator"
require "hiccup/enumerable/weekly_enumerator"
require "hiccup/errors"


module Hiccup
  module Enumerable



    def enumerator
      ScheduleEnumerator.enum_for(self)
    end



    def to_a
      raise UnboundedEnumerationError, "This schedule does not have an end date and so cannot be asked to list all of its dates, ever" unless ends?

      occurrences = []
      enum = enumerator.new(self, start_date)
      while occurrence = enum.next
        occurrences << occurrence
      end
      occurrences
    end



    def occurrences_between(earlier_date, later_date)
      occurrences = []
      enum = enumerator.new(self, earlier_date)
      while (occurrence = enum.next) && (occurrence <= later_date)
        occurrences << occurrence
      end
      occurrences
    end



    def first_occurrence_on_or_after(date)
      enumerator.new(self, date).next
    end

    def first_occurrence_after(date)
      first_occurrence_on_or_after(date.to_date + 1)
    end
    alias :next_occurrence_after :first_occurrence_after



    def first_occurrence_on_or_before(date)
      enumerator.new(self, date).prev
    end

    def first_occurrence_before(date)
      first_occurrence_on_or_before(date.to_date - 1)
    end



    def occurs_on(date)
      date = date.to_date
      date == first_occurrence_on_or_after(date)
    end
    alias :contains? :occurs_on
    alias :includes? :occurs_on
    alias :member? :occurs_on
    alias :predicts? :occurs_on



    def n_occurrences_before(limit, date, options={})
      n_occurrences_on_or_before(limit, date.to_date - 1, options)
    end

    def n_occurrences_on_or_before(limit, date, options={})
      exceptions = options.fetch(:except, [])
      occurrences = []
      enum = enumerator.new(self, date)
      while (occurrence = enum.prev) && occurrences.length < limit
        occurrences << occurrence unless exceptions.member?(occurrence)
      end
      occurrences
    end



    def first_n_occurrences(limit, options={})
      n_occurrences_on_or_after(limit, start_date, options)
    end

    def n_occurrences_after(limit, date, options={})
      n_occurrences_on_or_after(limit, date.to_date + 1, options)
    end

    def n_occurrences_on_or_after(limit, date, options={})
      exceptions = options.fetch(:except, [])
      occurrences = []
      enum = enumerator.new(self, date)
      while (occurrence = enum.next) && occurrences.length < limit
        occurrences << occurrence unless exceptions.member?(occurrence)
      end
      occurrences
    end



  end
end
