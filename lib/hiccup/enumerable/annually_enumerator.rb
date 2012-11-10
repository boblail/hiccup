require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class AnnuallyEnumerator < ScheduleEnumerator
      
      
      def initialize(*args)
        super
        
        # Use more efficient iterator methods unless
        # we have to care about leap years
        
        unless start_date.month == 2 && start_date.day == 29
          def self.next_occurrence_after(date)
            date.next_year(skip)
          end
          
          def self.next_occurrence_before(date)
            date.prev_year(skip)
          end
        end
      end
      
      
      def first_occurrence_on_or_after(date)
        year, month, day = date.year, start_date.month, start_date.day
        day = -1 if month == 2 && day == 29
        
        result = Date.new(year, month, day)
        year += 1 if result < date
        
        remainder = (year - start_date.year) % skip
        year += (skip - remainder) if remainder > 0
        
        Date.new(year, month, day)
      end
      
      def first_occurrence_on_or_before(date)
        year, month, day = date.year, start_date.month, start_date.day
        day = -1 if month == 2 && day == 29
        
        result = Date.new(year, month, day)
        year -= 1 if result > date
        
        # what if year is before start_date.year?
        remainder = (year - start_date.year) % skip
        year -= remainder if remainder > 0
        
        Date.new(year, month, day)
      end
      
      
    end
  end
end
