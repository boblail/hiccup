require "test_helper"

# Ideas: see 3/4/10, 3/5/11, 3/4/12 as closer to
#        a pattern than 3/4/10, 9/15/11, 3/4/12.

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
  
  
  
  test "should prefer guesses that predict too many results over guesses that predict too few" do
    
    # In this stream of dates, we could guess an annual recurrence on 1/15
    # or a monthly recurrence on the 15th.
    #
    #  - The annual recurrence would have zero bricks (no unfulfilled predictions), 
    #    but it would fail to predict 5 of the dates in this list.
    #
    #  - The monthly recurrence would have zero failures (there's nothing in
    #    in the list it _wouldn't_ predict), but it would have 6 bricks.
    #
    dates = %w{2011-1-15 2011-2-15 2011-5-15 2011-7-15 2011-8-15 2011-11-15 2012-1-15}
    
    # If bricks and fails were equal, the annual recurrence would be the
    # preferred guess, but the monthly one makes more sense.
    # It is better to brick than to fail.
    schedule = Schedule.infer(dates).first
    assert_equal :monthly, schedule.kind
  end
  
  
  
  
  
  # Infers annual schedules
  
  test "should infer an annual" do
    dates = %w{2010-3-4 2011-3-4 2012-3-4}
    schedules = Schedule.infer(dates)
    assert_equal ["Every year on March 4"], schedules.map(&:humanize)
  end
  
  
  # ... with skips
  
  test "should infer a schedule that occurs every other year" do
    dates = %w{2010-3-4 2012-3-4 2014-3-4}
    schedules = Schedule.infer(dates)
    assert_equal ["Every other year on March 4"], schedules.map(&:humanize)
  end
  
  # ... where some of the input is wrong
  
  test "should infer a yearly schedule when one of the dates was rescheduled" do
    dates = %w{2010-3-4 2011-9-15 2012-3-4 2013-3-4}
    schedules = Schedule.infer(dates)
    assert_equal ["Every year on March 4"], schedules.map(&:humanize)
  end
  
  test "should infer a yearly schedule when the first date was rescheduled" do
    dates = %w{2010-3-6 2011-3-4 2012-3-4 2013-3-4}
    schedules = Schedule.infer(dates)
    assert_equal ["Every year on March 4"], schedules.map(&:humanize)
  end
  
  
  
  
  
  # Infers monthly schedules
  
  test "should infer a monthly schedule that occurs on a date" do
    dates = %w{2012-2-4 2012-3-4 2012-4-4}
    schedules = Schedule.infer(dates)
    assert_equal ["The 4th of every month"], schedules.map(&:humanize)
    
    dates = %w{2012-2-17 2012-3-17 2012-4-17}
    schedules = Schedule.infer(dates)
    assert_equal ["The 17th of every month"], schedules.map(&:humanize)
  end
  
  test "should infer a monthly schedule that occurs on a weekday" do
    dates = %w{2012-7-9 2012-8-13 2012-9-10}
    schedules = Schedule.infer(dates)
    assert_equal ["The second Monday of every month"], schedules.map(&:humanize)
  end
  
  test "should infer a schedule that occurs several times a month" do
    dates = %w{2012-7-9 2012-7-23 2012-8-13 2012-8-27 2012-9-10 2012-9-24}
    schedules = Schedule.infer(dates)
    assert_equal ["The second Monday and fourth Monday of every month"], schedules.map(&:humanize)
  end
  
  
  # ... with skips
  
  test "should infer a schedule that occurs every third month" do
    dates = %w{2012-2-4 2012-5-4 2012-8-4}
    schedules = Schedule.infer(dates)
    assert_equal ["The 4th of every third month"], schedules.map(&:humanize)
  end
  
  
  # ... when some dates are wrong in the input group
  
  test "should infer a monthly (by day) schedule when one day was rescheduled" do
    dates = %w{2012-10-02 2012-11-02 2012-12-03}
    schedules = Schedule.infer(dates)
    assert_equal ["The 2nd of every month"], schedules.map(&:humanize)
  end
  
  test "should infer a monthly (by day) schedule when the first day was rescheduled" do
    dates = %w{2012-10-03 2012-11-02 2012-12-02}
    schedules = Schedule.infer(dates)
    assert_equal ["The 2nd of every month"], schedules.map(&:humanize)
  end
  
  
  test "should infer a monthly (by weekday) schedule when one day was rescheduled" do
    dates = %w{2012-10-02 2012-11-06 2012-12-05} # 1st Tuesday, 1st Tuesday, 1st Wednesday
    schedules = Schedule.infer(dates)
    assert_equal ["The first Tuesday of every month"], schedules.map(&:humanize)
  end
  
  test "should infer a monthly (by weekday) schedule when the first day was rescheduled" do
    dates = %w{2012-10-03 2012-11-01 2012-12-06} # 1st Wednesday, 1st Thursday, 1st Thursday
    schedules = Schedule.infer(dates)
    assert_equal ["The first Thursday of every month"], schedules.map(&:humanize)
  end
  
  test "should infer a monthly (by weekday) schedule when the first day was rescheduled 2" do
    dates = %w{2012-10-11 2012-11-01 2012-12-06} # 2nd Thursday, 1st Thursday, 1st Thursday
    schedules = Schedule.infer(dates)
    assert_equal ["The first Thursday of every month"], schedules.map(&:humanize)
  end
  
  
  
  
  
  # Infers weekly schedules
  
  test "should infer a weekly schedule" do
    dates = %w{2012-3-4 2012-3-11 2012-3-18}
    schedules = Schedule.infer(dates)
    assert_equal ["Every Sunday"], schedules.map(&:humanize)
  end
  
  test "should infer a schedule that occurs several times a week" do
    dates = %w{2012-3-6 2012-3-8 2012-3-13 2012-3-15 2012-3-20 2012-3-22}
    schedules = Schedule.infer(dates)
    assert_equal ["Every Tuesday and Thursday"], schedules.map(&:humanize)
  end
  
  
  # ... with skips
  
  test "should infer weekly recurrence for something that occurs every other week" do
    dates = %w{2012-3-6 2012-3-8 2012-3-20 2012-3-22}
    schedules = Schedule.infer(dates)
    assert_equal ["Tuesday and Thursday of every other week"], schedules.map(&:humanize)
  end
  
  
  # ... when some dates are missing from the input array
  
  test "should infer a weekly schedule (missing dates)" do
    dates = %w{2012-3-4 2012-3-11 2012-3-25}
    schedules = Schedule.infer(dates)
    assert_equal ["Every Sunday"], schedules.map(&:humanize)
  end
  
  test "should infer a schedule that occurs several times a week (missing dates)" do
    dates = %w{2012-3-6 2012-3-8 2012-3-15 2012-3-20 2012-3-27 2012-3-29}
    schedules = Schedule.infer(dates)
    assert_equal ["Every Tuesday and Thursday"], schedules.map(&:humanize)
  end
  
  
  # ... when some dates are wrong in the input group
  
  test "should infer a weekly schedule when one day was rescheduled" do
    dates = %w{2012-10-02 2012-10-09 2012-10-15} # a Tuesday, a Tuesday, and a Monday
    schedules = Schedule.infer(dates)
    assert_equal ["Every Tuesday"], schedules.map(&:humanize)
  end
  
  test "should infer a weekly schedule when the first day was rescheduled" do
    dates = %w{2012-10-07 2012-10-10 2012-10-17} # a Sunday, a Wednesday, and a Wednesday
    schedules = Schedule.infer(dates)
    assert_equal ["Every Wednesday"], schedules.map(&:humanize)
  end
  
  
  
  
  # Correctly identifies scenarios where there is no pattern
  
  test "should not try to guess a pattern for input where there is none" do
    arbitrary_date_ranges = [
      %w{2013-01-01 2013-03-30 2014-08-19},
      %w{2012-10-01 2012-10-09 2012-10-17}, # a Monday, a Tuesday, and a Wednesday
    ]
    
    arbitrary_date_ranges.each do |dates|
      schedules = Schedule.infer(dates)
      fail "There should be no pattern to the dates #{dates}, but Hiccup guessed \"#{schedules.map(&:humanize)}\"" if schedules.any?
    end
  end
  
  
  
  test "should infer multiple schedules from mixed input" do
    dates = %w{2012-11-05 2012-11-12 2012-11-19 2012-11-28 2012-12-05 2012-12-12} # three Mondays then three Wednesdays
    schedules = Schedule.infer(dates)
    assert_equal ["Every Monday", "Every Wednesday"],
      schedules.map(&:humanize)
  end
  
  
  
  test "should diabolically complex schedules" do
    dates = %w{2012-11-06 2012-11-08 2012-11-15 2012-11-20 2012-11-27 2012-11-29 2013-02-05 2013-02-14 2013-02-21 2013-02-19 2013-02-26 2013-05-07 2013-05-09 2013-05-16 2013-05-28 2013-05-21 2013-05-30}
    schedules = Schedule.infer(dates)
    assert_equal ["The first Tuesday, second Thursday, third Thursday, third Tuesday, fourth Tuesday, and fifth Thursday of every third month"], schedules.map(&:humanize)
  end
  
  
  
end
