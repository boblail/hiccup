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
    schedule = Schedule.infer(dates)
    assert_equal :monthly, schedule.kind
  end
  
  
  
  
  
  # Infers annual schedules
  
  test "should infer an annual" do
    dates = %w{2010-3-4 2011-3-4 2012-3-4}
    schedule = Schedule.infer(dates)
    assert_equal "Every year on March 4", schedule.humanize
  end
  
  
  # ... with skips
  
  test "should infer a schedule that occurs every other year" do
    dates = %w{2010-3-4 2012-3-4 2014-3-4}
    schedule = Schedule.infer(dates)
    assert_equal "Every other year on March 4", schedule.humanize
  end
  
  
  
  
  
  # Infers monthly schedules
  
  test "should infer a monthly schedule that occurs on a date" do
    dates = %w{2012-2-4 2012-3-4 2012-4-4}
    schedule = Schedule.infer(dates)
    assert_equal "The 4th of every month", schedule.humanize
    
    dates = %w{2012-2-17 2012-3-17 2012-4-17}
    schedule = Schedule.infer(dates)
    assert_equal "The 17th of every month", schedule.humanize
  end
  
  test "should infer a monthly schedule that occurs on a weekday" do
    dates = %w{2012-7-9 2012-8-13 2012-9-10}
    schedule = Schedule.infer(dates)
    assert_equal "The second Monday of every month", schedule.humanize
  end
  
  test "should infer a schedule that occurs several times a month" do
    dates = %w{2012-7-9 2012-7-23 2012-8-13 2012-8-27 2012-9-10 2012-9-24}
    schedule = Schedule.infer(dates)
    assert_equal "The second Monday and fourth Monday of every month", schedule.humanize
  end
  
  
  # ... with skips
  
  test "should infer a schedule that occurs every third month" do
    dates = %w{2012-2-4 2012-5-4 2012-8-4}
    schedule = Schedule.infer(dates)
    assert_equal "The 4th of every third month", schedule.humanize
  end
  
  
  # ... when some dates are wrong in the input group
  
  test "should infer a monthly schedule when one day was rescheduled" do
    dates = %w{2012-10-02 2012-11-06 2012-12-05} # 1st Tuesday, 1st Tuesday, 1st Wednesday
    schedule = Schedule.infer(dates)
    assert_equal "The first Tuesday of every month", schedule.humanize
  end
  
  test "should infer a monthly schedule when the first day was rescheduled" do
    dates = %w{2012-10-03 2012-11-01 2012-12-06} # 1st Wednesday, 1st Thursday, 1st Thursday
    schedule = Schedule.infer(dates)
    assert_equal "The first Thursday of every month", schedule.humanize
  end
  
  test "should infer a monthly schedule when the first day was rescheduled 2" do
    dates = %w{2012-10-11 2012-11-01 2012-12-06} # 2nd Thursday, 1st Thursday, 1st Thursday
    schedule = Schedule.infer(dates)
    assert_equal "The first Thursday of every month", schedule.humanize
  end
  
  
  
  
  
  # Infers weekly schedules
  
  test "should infer a weekly schedule" do
    dates = %w{2012-3-4 2012-3-11 2012-3-18}
    schedule = Schedule.infer(dates)
    assert_equal "Every Sunday", schedule.humanize
  end
  
  test "should infer a schedule that occurs several times a week" do
    dates = %w{2012-3-6 2012-3-8 2012-3-13 2012-3-15 2012-3-20 2012-3-22}
    schedule = Schedule.infer(dates)
    assert_equal "Every Tuesday and Thursday", schedule.humanize
  end
  
  
  # ... with skips
  
  test "should infer weekly recurrence for something that occurs every other week" do
    dates = %w{2012-3-6 2012-3-8 2012-3-20 2012-3-22}
    schedule = Schedule.infer(dates)
    assert_equal "Tuesday and Thursday of every other week", schedule.humanize
  end
  
  
  # ... when some dates are missing from the input array
  
  test "should infer a weekly schedule (missing dates)" do
    dates = %w{2012-3-4 2012-3-11 2012-3-25}
    schedule = Schedule.infer(dates)
    assert_equal "Every Sunday", schedule.humanize
  end
  
  test "should infer a schedule that occurs several times a week (missing dates)" do
    dates = %w{2012-3-6 2012-3-8 2012-3-15 2012-3-20 2012-3-27 2012-3-29}
    schedule = Schedule.infer(dates)
    assert_equal "Every Tuesday and Thursday", schedule.humanize
  end
  
  
  # ... when some dates are wrong in the input group
  
  test "should infer a weekly schedule when one day was rescheduled" do
    dates = %w{2012-10-02 2012-10-09 2012-10-15} # a Tuesday, a Tuesday, and a Monday
    schedule = Schedule.infer(dates)
    assert_equal "Every Tuesday", schedule.humanize
  end
  
  test "should infer a weekly schedule when the first day was rescheduled" do
    dates = %w{2012-10-07 2012-10-10 2012-10-17} # a Sunday, a Wednesday, and a Wednesday
    schedule = Schedule.infer(dates)
    assert_equal "Every Wednesday", schedule.humanize
  end
  
  
  
  
  # Correctly identifies scenarios where there is no pattern
  
  test "should not try to guess a pattern for input where there is none" do
    arbitrary_date_ranges = [
      %w{2013-01-01 2013-03-30 2014-08-19},
      %w{2012-10-01 2012-10-09 2012-10-17}, # a Monday, a Tuesday, and a Wednesday
    ]
    
    arbitrary_date_ranges.each do |dates|
      schedule = Schedule.infer(dates)
      fail "There should be no pattern to the dates #{dates}, but Hiccup guessed \"#{schedule.humanize}\"" if schedule
    end
  end
  
end
