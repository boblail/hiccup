module Hiccup
  module Enumerable
    class ScheduleEnumerator
      
      def self.enum_for(schedule)
        case schedule.kind
        when :weekly then WeeklyEnumerator
        when :annually then AnnuallyEnumerator
        when :monthly then MonthlyEnumerator.for(schedule)
        else NeverEnumerator
        end
      end
      
      
      
      def initialize(schedule, seed_date)
        @schedule = schedule
        @ends = schedule.ends?
        @seed_date = seed_date
        @seed_date = seed_date.to_date if seed_date.respond_to?(:to_date)
        @cursor = nil
      end
      
      attr_reader :schedule, :seed_date, :cursor
      
      
      
      def next
        @cursor = started? ? advance! : first_occurrence_on_or_after(seed_start_date)
        return nil if ends? && @cursor > end_date
        @cursor
      end
      
      def prev
        @cursor = started? ? rewind! : first_occurrence_on_or_before(seed_end_date)
        return nil if @cursor < start_date
        @cursor
      end
      
      
      
      def started?
        !@cursor.nil?
      end
      
      def ends?
        @ends
      end
      
      
      
    protected
      
      
      
      delegate :start_date, :weekly_pattern, :monthly_pattern, :end_date, :skip, :to => :schedule
      
      
      
      def leap_year?(year)
        return false unless (year % 4).zero?
        return (year % 400).zero? if (year % 100).zero?
        true
      end
      
      
      
      def seed_start_date
        return start_date if (seed_date < start_date)
        seed_date
      end
      
      def seed_end_date
        return end_date if (ends? && seed_date > end_date)
        seed_date
      end
      
      
      
      # These two methods DO assume that
      # date is predicted by the given schedule
      # Subclasses can probably supply more
      # performant implementations of these.
      
      def advance!
        puts "calling ScheduleEnumerator#advance! slow!"
        first_occurrence_on_or_after(cursor + 1)
      end
      
      def rewind!
        puts "calling ScheduleEnumerator#rewind! slow!"
        first_occurrence_on_or_before(cursor - 1)
      end
      
      
      
      # These two methods DO NOT assume that
      # date is predicted by the given schedule
      # Subclasses _must_ provide implementations
      # of these methods.
      
      def first_occurrence_on_or_after(date)
        raise NotImplementedError
      end
      
      def first_occurrence_on_or_before(date)
        raise NotImplementedError
      end
      
      
      
    end
  end
end
