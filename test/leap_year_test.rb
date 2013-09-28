require "test_helper"


class LeapYearTest < ActiveSupport::TestCase
  include Hiccup
  
  
  
  test "should correctly determine whether a year is a leap year or not" do
    enum = Enumerable::ScheduleEnumerator.new(Schedule.new, Date.today)
    
    assert enum.send(:leap_year?, 1988), "1988 is a leap year"
    assert enum.send(:leap_year?, 2000), "2000 is a leap year"
    refute enum.send(:leap_year?, 1998), "1998 is not a leap year"
    refute enum.send(:leap_year?, 1900), "1900 is not a leap year"
  end
  
  
  
end
