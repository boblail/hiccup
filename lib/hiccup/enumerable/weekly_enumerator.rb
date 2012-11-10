require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class WeeklyEnumerator < ScheduleEnumerator
      
      
      def initialize(*args)
        super
        
        # Use more efficient iterator methods if
        # weekly_pattern is simple enough
        
        if weekly_pattern.length == 1
          def self.next_occurrence_after(date)
            date + skip * 7
          end
          
          def self.next_occurrence_before(date)
            date - skip * 7
          end
        end
      end
      
      
      def first_occurrence_on_or_after(date)        
        result = nil
        wday = date.wday
        weekly_pattern.each do |weekday|
          wd = Date::DAYNAMES.index(weekday)
          wd = wd + 7 if wd < wday
          days_in_the_future = wd - wday
          temp = date + days_in_the_future
          
          remainder = ((temp - start_date) / 7).to_i % skip
          temp += (skip - remainder) * 7 if remainder > 0
          
          result = temp if !result || (temp < result)
        end
        result
      end
      
      def first_occurrence_on_or_before(date)
        result = nil
        wday = date.wday
        weekly_pattern.each do |weekday|
          wd = Date::DAYNAMES.index(weekday)
          wd = wd - 7 if wd > wday
          days_in_the_past = wday - wd
          temp = date - days_in_the_past
          
          remainder = ((temp - start_date) / 7).to_i % skip
          temp -= remainder * 7 if remainder > 0
          
          result = temp if !result || (temp > result)
        end
        result
      end
      
      
    end
  end
end
