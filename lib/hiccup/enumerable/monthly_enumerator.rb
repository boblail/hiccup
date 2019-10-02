require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class MonthlyEnumerator < ScheduleEnumerator

      def self.for(schedule)
        if schedule.monthly_pattern.empty?
          NeverEnumerator
        elsif schedule.monthly_pattern.all? { |occurrence| Integer === occurrence }
          MonthlyDateEnumerator
        else
          self
        end
      end



      def started?
        !@position.nil?
      end



    protected

      attr_reader :year, :month, :cycle, :last_day_of_month



      def advance!
        @position += 1
        next_month if @position >= cycle.length

        day = cycle[@position]
        return self.next if day > last_day_of_month
        Date.new(year, month, day)
      rescue
        advance!
      end

      def rewind!
        @position -= 1
        prev_month if @position < 0

        day = cycle[@position]
        return self.prev if day > last_day_of_month
        Date.new(year, month, day)
      rescue
        rewind!
      end



      def first_occurrence_on_or_after(date)
        @year, @month, seed_day = date.year, date.month, date.day
        if skip > 1
          offset = months_since_schedule_start(@year, @month)
          remainder = offset % skip
          if remainder > 0
            add_to_months remainder
            seed_day = first_day_of_month
          end
        end

        get_context

        @position = cycle.index { |day| day >= seed_day }
        next_month unless @position

        day = cycle[@position]
        return self.next if day > last_day_of_month
        Date.new(year, month, day)
      rescue
        advance!
      end

      def first_occurrence_on_or_before(date)
        @year, @month, seed_day = date.year, date.month, date.day
        if skip > 1
          offset = months_since_schedule_start(@year, @month)
          remainder = offset % skip
          if remainder > 0
            subtract_from_months remainder
            get_context # figure out last_day_of_month
            seed_day = last_day_of_month
          end
        end

        get_context

        @position = cycle.rindex { |day| day <= seed_day }
        prev_month unless @position

        day = cycle[@position]
        return self.prev if day > last_day_of_month
        Date.new(year, month, day)
      rescue
        rewind!
      end



      def occurrences_in_month(year, month)
        monthly_pattern.map do |occurrence|
          if occurrence.is_a?(Array)
            ordinal, weekday = occurrence
            wday = Date::DAYNAMES.index(weekday)
            day = wday
            if ordinal < 0
              wday_of_last_of_month = Date.new(year, month, -1).wday
              day = day + 7 if wday <= wday_of_last_of_month
              day = day - wday_of_last_of_month + (ordinal * 7)
              day = last_day_of_month + day
            else
              wday_of_first_of_month = Date.new(year, month, 1).wday
              day = day + 7 if (wday < wday_of_first_of_month)
              day = day - wday_of_first_of_month
              day = day + (ordinal * 7) - 6
            end
            day
          else
            coerce_day_to_positive(occurrence)
          end
        end.uniq
      end



      def next_month
        @position = 0
        add_to_months skip
        get_context
      end

      def add_to_months(offset)
        @month += offset
        @year, @month = @year + 1, @month - 12 while @month > 12
      end

      def prev_month
        @position = @cycle.length - 1
        subtract_from_months skip
        get_context
      end

      def subtract_from_months(offset)
        @month -= offset
        @year, @month = @year - 1, @month + 12 while @month < 1
      end

      def get_context
        @last_day_of_month = [4, 6, 9, 11].member?(month) ? 30 : 31
        @last_day_of_month = leap_year?(year) ? 29 : 28 if month == 2
        @cycle = occurrences_in_month(year, month).sort
      end



      def months_since_schedule_start(year, month)
        (year - start_date.year) * 12 + (month - start_date.month)
      end

      def first_day_of_month
        1
      end


      def coerce_day_to_positive(index)
        # Converts e.g. -1 (last day of the month) to 31
        return index if index > 0
        last_day_of_month + index + 1
      end

    end
  end
end

require "hiccup/enumerable/monthly_date_enumerator"
