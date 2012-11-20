require "hiccup/core_ext/date"
require "hiccup/enumerable/annually_enumerator"
require "hiccup/enumerable/monthly_enumerator"
require "hiccup/enumerable/never_enumerator"
require "hiccup/enumerable/weekly_enumerator"


module Hiccup
  module Enumerable
    
    
    
    def enumerator
      @enumerator ||= "Hiccup::Enumerable::#{kind.to_s.classify}Enumerator".constantize
    end
    
    def kind=(value)
      super
      @enumerator = nil
    end
    
    
    
    def occurrences_during_month(year, month)
      date1 = Date.new(year, month, 1)
      date2 = Date.new(year, month, -1)
      occurrences_between(date1, date2)
    end
    
    
    
    def occurrences_between(earlier_date, later_date)
      earlier_date = start_date if earlier_date < start_date
      
      occurrences = []
      enum = enumerator.new(self, earlier_date)
      while (occurrence = enum.next) && (occurrence <= later_date)
        occurrences << occurrence
      end
      occurrences
    end
    
    
    
    def first_occurrence_on_or_after(date)
      date = start_date if (date < start_date)
      enumerator.new(self, date).next
    end
    
    def first_occurrence_after(date)
      first_occurrence_on_or_after(date.to_date + 1)
    end
    alias :next_occurrence_after :first_occurrence_after
    
    
    
    def first_occurrence_on_or_before(date)
      date = end_date if (ends? && date > end_date)
      enumerator.new(self, date).prev
    end
    
    def first_occurrence_before(date)
      first_occurrence_on_or_before(date.to_date - 1)
    end
    
    
    
    def occurs_on(date)
      date = date.to_date
      first_occurrence_on_or_after(date).eql?(date)
    end
    alias :contains? :occurs_on
    
    
    
    def n_occurrences_before(limit, date)
      n_occurrences_on_or_before(limit, date.to_date - 1)
    end
    
    def n_occurrences_on_or_before(limit, date)
      date = end_date if (ends? && date > end_date)
      
      occurrences = []
      enum = enumerator.new(self, date)
      while (occurrence = enum.prev) && occurrences.length < limit
        occurrences << occurrence
      end
      occurrences
    end
    
    
    
  end
end
