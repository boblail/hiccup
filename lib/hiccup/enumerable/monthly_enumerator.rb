require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class MonthlyEnumerator < ScheduleEnumerator
      
      
      def self.for(schedule)
        if schedule.monthly_pattern.all? { |occurrence| Fixnum === occurrence }
          MonthlyDateEnumerator
        else
          self
        end
      end
      
      
      def first_occurrence_on_or_after(date)
        result = nil
        monthly_pattern.each do |occurrence|
          temp = nil
          (0...30).each do |i| # If an occurrence doesn't occur this month, try up to 30 months in the future
            temp = monthly_occurrence_to_date(occurrence, shift_date_by_months(date, i))
            break if temp && (temp >= date)
          end
          next unless temp
          
          remainder = months_between(temp, start_date) % skip
          temp = monthly_occurrence_to_date(occurrence, shift_date_by_months(temp, skip - remainder)) if remainder > 0
          next unless temp
          
          result = temp if !result || (temp < result)
        end
        result
      end
      
      def first_occurrence_on_or_before(date)
        result = nil
        monthly_pattern.each do |occurrence|
          temp = nil
          (0...30).each do |i| # If an occurrence doesn't occur this month, try up to 30 months in the past
            temp = monthly_occurrence_to_date(occurrence, shift_date_by_months(date, -i))
            break if temp && (temp <= date)
          end
          next unless temp
          
          remainder = months_between(temp, start_date) % skip
          temp = monthly_occurrence_to_date(occurrence, shift_date_by_months(temp, -remainder)) if remainder > 0
          next unless temp
          
          result = temp if !result || (temp > result)
        end
        result
      end
      
      
    private
      
      
      def shift_date_by_months(date, months)
        date.next_month(months)
      end
      
      
      def monthly_occurrence_to_date(occurrence, date)
        year, month = date.year, date.month
        
        day = begin
          if occurrence.is_a?(Array)
            ordinal, weekday = occurrence
            wday_of_first_of_month = Date.new(year, month, 1).wday
            wday = Date::DAYNAMES.index(weekday)
            day = wday
            day = day + 7 if (wday < wday_of_first_of_month)
            day = day - wday_of_first_of_month
            day = day + (ordinal * 7) - 6
          else
            occurrence
          end
        end
        
        last_day_of_month = Date.new(year, month, -1).day
        (day > last_day_of_month) ? nil : Date.new(year, month, day)
      end
      
      
      def months_between(later_date, earlier_date)
        ((later_date.year - earlier_date.year) * 12) + (later_date.month - earlier_date.month).to_int
      end
      
      
    end
  end
end

require "hiccup/enumerable/monthly_date_enumerator"
