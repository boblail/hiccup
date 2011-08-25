require "hiccup/convenience"
require "hiccup/core_ext/date"
require "hiccup/core_ext/duration"


module Hiccup
  module Enumerable
    include Convenience
    
    
    
    def occurrences_during_month(year, month)
      date1 = Date.new(year, month, 1)
      date2 = date1.at_end_of_month
      occurrences_between(date1, date2)
    end
    
    
    
    def occurrences_between(earlier_date, later_date)
      [].tap do |occurrences|
        if (!ends? || earlier_date <= end_date) && (later_date >= start_date)
          earlier_date = start_date if (earlier_date < start_date)
          later_date = end_date if ends? && (later_date > end_date)
          occurrence = first_occurrence_on_or_after(earlier_date)
          while occurrence && (occurrence <= later_date)
            occurrences << occurrence
            occurrence = next_occurrence_after(occurrence)
          end
        end
      end
    end
    
    
    
    def first_occurrence_on_or_after(date)
      date = date.to_date unless date.is_a?(Date) || !date.respond_to?(:to_date)
      date = self.start_date if (date < self.start_date)
      
      result = nil
      case kind
      when :never
        result = date if date == self.start_date # (date > self.start_date) ? nil : self.start_date
      
      when :weekly
        wday = date.wday
        pattern.each do |weekday|
          wd = Date::DAYNAMES.index(weekday)
          wd = wd + 7 if wd < wday
          days_in_the_future = wd - wday
          temp = days_in_the_future.days.after(date)
          
          remainder = ((temp - start_date) / 7).to_i % skip
          temp = (skip - remainder).weeks.after(temp) if (remainder > 0)
          
          result = temp if !result || (temp < result)
        end
      
      when :monthly
        pattern.each do |occurrence|
          temp = nil
          (0...30).each do |i| # If an occurrence doesn't occur this month, try up to 30 months in the future
            temp = monthly_occurrence_to_date(occurrence, i.months.after(date))
            break if temp && (temp >= date)
          end
          next unless temp
          
          remainder = months_between(temp, start_date) % skip
          temp = monthly_occurrence_to_date(occurrence, (skip - remainder).months.after(temp)) if (remainder > 0)        
          
          result = temp if !result || (temp < result)
        end
      
      when :annually
        result, try_to_use_2_29 = if((start_date.month == 2) && (start_date.day == 29))
          [Date.new(date.year, 2, 28), true]
        else
          [Date.new(date.year, start_date.month, start_date.day), false]
        end
        result = 1.year.after(result) if (result < date)
        
        remainder = years_between(result, start_date) % skip
        result = (skip - remainder).years.after(result) if (remainder > 0)
        
        if try_to_use_2_29
          begin
            date = Date.new(result.year, 2, 29)
          rescue
          end
        end
      end
      
      result = nil if (self.ends? && result && result > self.end_date)
      result
    end
    
    
    
    def next_occurrence_after(date)
      first_occurrence_on_or_after(1.day.after(date))
    end
    
    
    
    def first_occurrence_on_or_before(date)
      date = date.to_date unless date.is_a?(Date) || !date.respond_to?(:to_date)
      date = self.end_date if (self.ends? && date > self.end_date)
      
      result = nil
      case kind
      when :never
        result = date # (date > self.start_date) ? nil : self.start_date
      
      when :weekly
        wday = date.wday
        pattern.each do |weekday|
          wd = Date::DAYNAMES.index(weekday)
          wd = wd - 7 if wd > wday
          days_in_the_past = wday - wd
          temp = days_in_the_past.days.before(date)
          
          remainder = ((temp - start_date) / 7).to_i % skip
          temp = remainder.weeks.before(temp) if (remainder > 0)
          
          result = temp if !result || (temp > result)
        end
      
      when :monthly
        pattern.each do |occurrence|
          temp = nil
          (0...30).each do |i| # If an occurrence doesn't occur this month, try up to 30 months in the past
            temp = monthly_occurrence_to_date(occurrence, i.months.before(date))
            break if temp && (temp <= date)
          end
          next unless temp
          
          remainder = months_between(temp, start_date) % skip
          temp = monthly_occurrence_to_date(occurrence, remainder.months.before(temp)) if (remainder > 0)        
          
          result = temp if !result || (temp > result)
        end
      
      when :annually
        result, try_to_use_2_29 = if((start_date.month == 2) && (start_date.day == 29))
          [Date.new(date.year, 2, 28), true]
        else
          [Date.new(date.year, start_date.month, start_date.day), false]
        end
        result = 1.year.before(result) if (result < date)

        remainder = years_between(result, start_date) % skip
        result = remainder.years.before(result) if (remainder > 0)
        if try_to_use_2_29
          begin
            date = Date.new(result.year, 2, 29)
          rescue
          end
        end
      end
      
      result = nil if (result && result < self.start_date)
      result
    end
    
    
    
    def first_occurrence_before(date)
      first_occurrence_on_or_before(1.day.before(date))
    end
    
    
    
    def occurs_on(date)
      date = date.to_date
      first_occurrence_on_or_after(date).eql?(date)
    end
    alias :contains? :occurs_on
    
    
    
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
    
    
    
  private
    
    
    
    def months_between(date1, date2)
      later_date, earlier_date = sort_dates(date1, date2)
      later_date.get_months_since(earlier_date)
    end
    
    def weeks_between(date1, date2)
      later_date, earlier_date = sort_dates(date1, date2)
      later_date.get_weeks_since(earlier_date)
    end
    
    def years_between(date1, date2)
      later_date, earlier_date = sort_dates(date1, date2)
      later_date.get_years_since(earlier_date)
    end
    
    def sort_dates(date1, date2)
      (date1 > date2) ? [date1, date2] : [date2, date1]
    end
    
    
    
  end
end
