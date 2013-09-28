require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class MonthlyDateEnumerator < MonthlyEnumerator
      
      
      alias :cycle :monthly_pattern
      
      
      def next
        if @current_date
          @position += 1
          year, month = @current_date.year, @current_date.month
          if @position >= cycle.length
            @position = 0
            month += skip
            year, month = year + 1, month - 12 if month > 12
          end
          day = cycle[@position]
          if day >= 28
            last_day_of_month = Date.new(year, month, -1).day
            if day > last_day_of_month
              @current_date = Date.new(year, month, last_day_of_month)
              return self.next
            end
          end
          @current_date = Date.new(year, month, day)
        else
          @current_date = first_occurrence_on_or_after(@date)
          @position = cycle.index(@current_date.day)
        end
        
        @current_date = nil if (ends? && @current_date && @current_date > end_date)
        @current_date
      end
      
      
      def prev
        if @current_date
          @position -= 1
          year, month = @current_date.year, @current_date.month
          if @position < 0
            @position = @cycle.length - 1
            month -= skip
            year, month = year - 1, month + 12 if month < 1
          end
          day = cycle[@position]
          if day >= 28
            last_day_of_month = Date.new(year, month, -1).day
            if day > last_day_of_month
              @current_date = Date.new(year, month, last_day_of_month)
              return self.prev
            end
          end
          @current_date = Date.new(year, month, day)
        else
          @current_date = first_occurrence_on_or_before(@date)
          @position = cycle.index(@current_date.day)
        end
        
        @current_date = nil if (@current_date && @current_date < start_date)
        @current_date
      end
      
      
    end
  end
end
