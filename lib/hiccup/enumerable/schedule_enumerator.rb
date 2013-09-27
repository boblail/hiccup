
module Hiccup
  module Enumerable
    class ScheduleEnumerator
      
      def initialize(schedule, date)
        @schedule = schedule
        @date = date
        @date = @date.to_date if @date.respond_to?(:to_date)
        @date = start_date if (@date < start_date)
        @date = end_date if (ends? && @date > end_date)
        @current_date = nil
      end
      
      attr_reader :schedule
      delegate :start_date, :weekly_pattern, :monthly_pattern, :ends?, :end_date, :skip, :to => :schedule
      
      
      
      def next
        @current_date = if @current_date
          next_occurrence_after(@current_date)
        else
          first_occurrence_on_or_after(@date)
        end
        @current_date = nil if (@current_date && ends? && @current_date > end_date)
        @current_date
      end
      
      def prev
        @current_date = if @current_date
          next_occurrence_before(@current_date)
        else
          first_occurrence_on_or_before(@date)
        end
        @current_date = nil if (@current_date && @current_date < start_date)
        @current_date
      end
      
      
      
      # These two methods DO NOT assume that
      # date is predicted by the given schedule
      
      def first_occurrence_on_or_after(date)
        raise NotImplementedError
      end
      
      def first_occurrence_on_or_before(date)
        raise NotImplementedError
      end
      
      
      # These two methods DO assume that
      # date is predicted by the given schedule
      
      def next_occurrence_after(date)
        first_occurrence_on_or_after(date + 1)
      end
      
      def next_occurrence_before(date)
        first_occurrence_on_or_before(date - 1)
      end
      
      
      
    end
  end
end
