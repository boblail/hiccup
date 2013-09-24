require "hiccup/core_ext/date"
require "hiccup/enumerable/annually_enumerator"
require "hiccup/enumerable/monthly_enumerator"
require "hiccup/enumerable/never_enumerator"
require "hiccup/enumerable/weekly_enumerator"


module Hiccup
  module Enumerable
    
    
    
    def enumerator
      "Hiccup::Enumerable::#{kind.to_s.classify}Enumerator".constantize
    end
    
    
    
    def occurrences_during_month(year, month)
      puts "DEPRECATED: `occurrences_during_month` will be removed in 0.5.0. Use `occurrences_between` instead"
      date1 = Date.new(year, month, 1)
      date2 = Date.new(year, month, -1)
      occurrences_between(date1, date2)
    end
    
    
    
    def occurrences_between(earlier_date, later_date)
      return [] if ends? && earlier_date > end_date
      return [] if later_date < start_date
      
      occurrences = []
      enum = enumerator.new(self, earlier_date)
      while (occurrence = enum.next) && (occurrence <= later_date)
        occurrences << occurrence
      end
      occurrences
    end
    
    
    
    def first_occurrence_on_or_after(date)
      return nil if ends? && date > end_date
      enumerator.new(self, date).next
    end
    
    def first_occurrence_after(date)
      first_occurrence_on_or_after(date.to_date + 1)
    end
    alias :next_occurrence_after :first_occurrence_after
    
    
    
    def first_occurrence_on_or_before(date)
      return nil if date < start_date
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
    
    
    
    def n_occurrences_before(limit, date)
      n_occurrences_on_or_before(limit, date.to_date - 1)
    end
    
    def n_occurrences_on_or_before(limit, date)
      return [] if date < start_date
      
      occurrences = []
      enum = enumerator.new(self, date)
      while (occurrence = enum.prev) && occurrences.length < limit
        occurrences << occurrence
      end
      occurrences
    end
    
    
    
    def first_n_occurrences(limit)
      n_occurrences_on_or_after(limit, start_date)
    end
    
    def n_occurrences_after(limit, date)
      n_occurrences_on_or_after(limit, date.to_date + 1)
    end
    
    def n_occurrences_on_or_after(limit, date)
      return [] if ends? and date > end_date
      
      occurrences = []
      enum = enumerator.new(self, date)
      while (occurrence = enum.next) && occurrences.length < limit
        occurrences << occurrence
      end
      occurrences
    end
    
    
    
  end
end
