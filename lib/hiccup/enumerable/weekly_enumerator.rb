require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class WeeklyEnumerator < ScheduleEnumerator
      
      def initialize(*args)
        super
        
        @wday_pattern = weekly_pattern.map do |weekday|
          Date::DAYNAMES.index(weekday)
        end.sort
        
        if @wday_pattern.empty?
          @base_date = start_date
          @starting_index = 0
          @cycle = []
          return
        end
        
        start_wday = start_date.wday
        if start_wday <= @wday_pattern.first or start_wday > @wday_pattern.last
          @base_date = start_date
        else
          @base_date = start_date - (start_wday - @wday_pattern.first)
        end
        
        @starting_index = wday_pattern.index { |wday| wday >= start_wday } || 0
        @cycle = calculate_cycle(schedule)
      end
      
    protected
      
      
      
      attr_reader :base_date,
                  :wday_pattern,
                  :starting_index,
                  :cycle,
                  :position
      
      
      
      def advance!
        date = cursor + cycle[position]
        @position = (position + 1) % cycle.length
        date
      end
      
      def rewind!
        @position = position <= 0 ? cycle.length - 1 : position - 1
        cursor - cycle[position]
      end
      
      
      
      def first_occurrence_on_or_after(date)
        result = nil
        wday = date.wday
        wday_pattern.each do |wd|
          wd = wd + 7 if wd < wday
          days_in_the_future = wd - wday
          temp = date + days_in_the_future
          
          remainder = ((temp - base_date) / 7).to_i % skip
          temp += (skip - remainder) * 7 if remainder > 0
          
          result = temp if !result || (temp < result)
        end
        @position = position_of(result) if result
        result
      end
      
      def first_occurrence_on_or_before(date)
        result = nil
        wday = date.wday
        wday_pattern.each do |wd|
          wd = wd - 7 if wd > wday
          days_in_the_past = wday - wd
          temp = date - days_in_the_past
          
          remainder = ((temp - base_date) / 7).to_i % skip
          temp -= remainder * 7 if remainder > 0
          
          result = temp if !result || (temp > result)
        end
        @position = position_of(result) if result
        result
      end
      
      
      
      def calculate_cycle(schedule)
        cycle = []
        offset = wday_pattern[starting_index]
        wdays = wday_pattern.map { |wday| wday - offset }.sort
        
        while wdays.first <= 0
          wdays.push (wdays.shift + 7 * skip)
        end
        
        cycle = [wdays.first]
        wdays.each_cons(2) do |wday1, wday2|
          cycle << (wday2 - wday1)
        end
        cycle
      end
      
      def position_of(date)
        date_i = wday_pattern.index(date.wday)
        position = date_i - starting_index
        position += wday_pattern.length if position < 0
        position
      end
      
      
      
    end
  end
end
