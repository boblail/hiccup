require "test_helper"


class InferrableTest < ActiveSupport::TestCase
  include Hiccup
  
  
  
  test "should raise an error if not given an array of dates" do
    assert_raises ArgumentError do
      Schedule.infer(["what's this?"])
    end
  end
  
  test "extract_array_of_dates! should interpret date-like things as dates" do
    datelike_things = [Date.today, Time.now, DateTime.new(2012, 8, 17)]
    dates = Schedule.extract_array_of_dates!(datelike_things)
    assert_equal datelike_things.length, dates.length
    assert dates.all? { |date| date.is_a?(Date) }, "Expected these to all be dates, but they were #{dates.map(&:class)}"
  end
  
  test "extract_array_of_dates! should put dates in order" do
    input_dates = %w{2014-01-01 2007-01-01 2009-01-01}
    expected_dates = %w{2007-01-01 2009-01-01 2014-01-01}
    dates = Schedule.extract_array_of_dates!(input_dates)
    assert_equal expected_dates, dates.map(&:to_s)
  end
  
  
  
  test "should infer annual recurrence from something that occurs three years in a row" do
    dates = %w{2010-3-4 2011-3-4 2012-3-4}
    schedule = Schedule.infer(dates)
    assert_equal :annually, schedule.kind
  end
  
  test "should infer monthly recurrence from something that occurs three months in a row on the same date" do
    dates = %w{2012-2-4 2012-3-4 2012-4-4}
    schedule = Schedule.infer(dates)
    assert_equal :monthly, schedule.kind
  end
  
  test "should infer weekly recurrence from something that occurs three weeks in a row on the same day" do
    dates = %w{2012-3-4 2012-3-11 2012-3-18}
    schedule = Schedule.infer(dates)
    assert_equal :weekly, schedule.kind
    assert_equal ["Sunday"], schedule.weekly_pattern
  end
  
  
  
end
