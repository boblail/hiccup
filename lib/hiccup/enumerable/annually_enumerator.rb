require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class AnnuallyEnumerator < ScheduleEnumerator

      def initialize(*args)
        super
        @month, @day = start_date.month, start_date.day

        if month == 2 and day == 29
          def self.current_date
            Date.new(year, 2, leap_year?(year) ? 29 : 28)
          end
        end
      end

      attr_reader :month, :day

    protected

      attr_reader :year



      def advance!
        @year += skip
        current_date
      rescue
        advance!
      end

      def rewind!
        @year -= skip
        current_date
      rescue
        rewind!
      end



      def first_occurrence_on_or_after(date)
        @year = date.year
        @year += 1 if (date.month > month) or (date.month == month and date.day > day)

        remainder = (@year - start_date.year) % skip
        @year += (skip - remainder) if remainder > 0

        current_date
      rescue
        advance!
      end

      def first_occurrence_on_or_before(date)
        @year = date.year
        @year -= 1 if (date.month < month) or (date.month == month and date.day < day)

        remainder = (@year - start_date.year) % skip
        @year -= remainder if remainder > 0

        current_date
      rescue
        rewind!
      end



      def current_date
        Date.new(year, month, day)
      end



    end
  end
end
