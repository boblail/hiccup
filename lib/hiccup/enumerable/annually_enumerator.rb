require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class AnnuallyEnumerator < ScheduleEnumerator
      
      def initialize(*args)
        super
        @month, @day = start_date.month, start_date.day
        @february_29 = month == 2 and day == 29
      end
      
    protected
      
      
      attr_reader :month, :day, :year
      
      def february_29?
        @february_29
      end
      
      
      
      def advance!
        @year += skip
        to_date!
      end
      
      def rewind!
        @year -= skip
        to_date!
      end
      
      
      
      def first_occurrence_on_or_after(date)
        @year = date.year
        @year += skip if (date.month > month) or (date.month == month and date.day > day)
        
        remainder = (@year - start_date.year) % skip
        @year += (skip - remainder) if remainder > 0
        
        to_date!
      end
      
      def first_occurrence_on_or_before(date)
        @year = date.year
        @year -= 1 if (date.month < month) or (date.month == month and date.day < day)
        
        remainder = (@year - start_date.year) % skip
        @year -= remainder if remainder > 0
        
        to_date!
      end
      
      
      
      def to_date!
        return Date.new(year, month, 28) if february_29? and !leap_year?(year)
        Date.new(year, month, day)
      end
      
      
      
    end
  end
end
