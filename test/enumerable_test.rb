require "test_helper"


class EnumerableTest < ActiveSupport::TestCase
  include Hiccup
  
  
  
  def test_occurs_on_annually
    schedule = Schedule.new({
      :kind => :annually,
      :start_date => Date.new(2009,3,15)})
    assert !schedule.occurs_on(Date.new(1984,3,15)),  "Annual schedule starting 3/15/09 should not occur on 3/15/1984"
    assert schedule.occurs_on(Date.new(2084,3,15)),   "Annual schedule starting 3/15/09 should occur on 3/15/2084"    
    assert !schedule.occurs_on(Date.new(2011,4,15)),  "Annual schedule starting 3/15/09 should not occur on 4/15/2011"
    assert !schedule.occurs_on(Date.new(2009,3,17)),  "Annual schedule starting 3/15/09 should not occur on 3/17/2009"
  end 
  
  
  
  test "annual recurrence with a skip" do
    schedule = Schedule.new({
      :kind => :annually,
      :skip => 2,
      :start_date => Date.new(2009,3,4)})
    expected_dates = %w{2009-03-04 2011-03-04 2013-03-04}
    actual_dates = schedule.occurrences_between(Date.new(2009, 01, 01), Date.new(2013, 12, 31)).map(&:to_s)
    assert_equal expected_dates, actual_dates
  end
  
  
  
  def test_occurs_on_weekly
    schedule = Schedule.new({
      :kind => :weekly,
      :weekly_pattern => %w{Monday Wednesday Friday},
      :start_date => Date.new(2009,3,15)})
    assert schedule.occurs_on(Date.new(2009,5,1)),    "MWF schedule starting 3/15/09 should occur on 5/1/2009"
    assert schedule.occurs_on(Date.new(2009,5,11)),   "MWF schedule starting 3/15/09 should occur on 5/11/2009"
    assert schedule.occurs_on(Date.new(2009,5,20)),   "MWF schedule starting 3/15/09 should occur on 5/20/2009"
    assert !schedule.occurs_on(Date.new(2009,3,15)),  "MWF schedule starting 3/15/09 should not occur on 3/15/2009"
    assert schedule.occurs_on(Date.new(2009,3,16)),   "MWF schedule starting 3/15/09 should occur on 3/16/2009"
    assert !schedule.occurs_on(Date.new(2009,3,11)),  "MWF schedule starting 3/15/09 should not occur on 3/11/2009"
    assert schedule.occurs_on(Date.new(2009,3,18)),   "MWF schedule starting 3/15/09 should occur on 3/18/2009"
    
    schedule.end_date = Date.new(2009,4,11)
    schedule.ends = true
    assert_equal true, schedule.ends?
    assert !schedule.occurs_on(Date.new(2009,5,1)),   "MWF schedule starting 3/15/09 and ending 4/11/09 should not occur on 5/1/2009"
    assert !schedule.occurs_on(Date.new(2009,5,11)),  "MWF schedule starting 3/15/09 and ending 4/11/09 should not occur on 5/11/2009"
    assert !schedule.occurs_on(Date.new(2009,5,20)),  "MWF schedule starting 3/15/09 and ending 4/11/09 should not occur on 5/20/2009"
  end
  
  
  
  def test_weekly_occurrences_during_month
    schedule = Schedule.new({
      :kind => :weekly,
      :weekly_pattern => %w{Monday Wednesday Friday},
      :start_date => Date.new(2009,3,15),
      :ends => true,
      :end_date => Date.new(2009,11,30)})
    dates = occurrences_during_month(schedule, 2009,7).map {|date| date.day}
    expected_dates = [1,3,6,8,10,13,15,17,20,22,24,27,29,31]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for weekly schedule"
    
    dates = occurrences_during_month(schedule, 2008,7).map {|date| date.day}
    expected_dates = []
    assert_equal expected_dates, dates,                 "occurrences_during_month should generate no occurrences if before start_date"
    
    schedule = Schedule.new({
      :kind => :weekly,
      :weekly_pattern => %w{Monday},
      :start_date => Date.new(2010,6,14),
      :ends => true,
      :end_date => Date.new(2010,6,21)})
    dates = occurrences_during_month(schedule, 2010,6).map {|date| date.day}
    expected_dates = [14,21]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not correctly observe end date for weekly schedule"
  end
  
  test "should keep weekly occurrences during a week together when skipping" do
    schedule = Schedule.new(
      :kind => :weekly,
      :weekly_pattern => %w{Tuesday Thursday},
      :start_date => Date.new(2013, 10, 2), # Wednesday
      :skip => 2)
    
    dates = occurrences_during_month(schedule, 2013, 10).map(&:day)
    assert_equal [3,  15, 17,  29, 31], dates
  end
  
  
  
  def test_monthly_occurrences_during_month
    schedule = Schedule.new({
      :kind => :monthly,
      :monthly_pattern => [[2, "Sunday"], [4, "Sunday"]],
      :start_date => Date.new(2004,3,15)})
    dates = occurrences_during_month(schedule, 2009,12).map {|date| date.day}
    expected_dates = [13,27]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for monthly schedule"
    
    dates = occurrences_during_month(schedule, 2009,2).map {|date| date.day}
    expected_dates = [8,22]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for monthly schedule"
    
    dates = occurrences_during_month(schedule, 1991,7).map {|date| date.day}
    expected_dates = []
    assert_equal expected_dates, dates,                 "occurrences_during_month should generate no occurrences if before start_date"
  end
  
  
  
  def test_no_occurrence
    expected_date = Date.new(2011,3,12)
    schedule = Schedule.new({:kind => :never, :start_date => expected_date})
    expected_dates = [expected_date]
    assert_equal expected_dates, schedule.occurrences_between(Date.new(2011,1,1), Date.new(2011,12,31))
    assert schedule.contains?(expected_date)
  end
  
  
  
  def test_n_occurrences_before
    schedule = Schedule.new({
      :kind => :weekly,
      :weekly_pattern => %w{Monday Wednesday Friday},
      :start_date => Date.new(2009,3,15),
      :ends => true,
      :end_date => Date.new(2009,11,30)})
    dates = schedule.n_occurrences_before(10, Date.new(2009, 10, 31)).map { |date| date.strftime("%Y-%m-%d") }
    
    expected_dates = ["2009-10-30", "2009-10-28", "2009-10-26",
                      "2009-10-23", "2009-10-21", "2009-10-19",
                      "2009-10-16", "2009-10-14", "2009-10-12",
                      "2009-10-09" ]
    assert_equal expected_dates, dates
  end
  
  test "n_occurrences_before should return a shorter array if no events exist before the given date" do
    schedule = Schedule.new({
      :kind => :weekly,
      :weekly_pattern => %w{Monday Wednesday Friday},
      :start_date => Date.new(2009,3,15),
      :ends => true,
      :end_date => Date.new(2009,11,30)})
    dates = schedule.n_occurrences_before(10, Date.new(2009, 3, 20)).map { |date| date.strftime("%Y-%m-%d") }
    
    expected_dates = ["2009-03-18", "2009-03-16"]
    assert_equal expected_dates, dates
  end
  
  
  
  def test_how_contains_handles_parameter_types
    date = Date.new(1981,4,23)
    schedule = Schedule.new({:kind => :annually, :start_date => date})
    assert schedule.contains?(date)
    assert schedule.contains?(date.to_time)
    assert schedule.contains?(date.to_datetime)
  end
  
  
  
  def test_monthly_occurrences
    occurrence = [1, "Wednesday"]
    schedule = Schedule.new({
      :kind => :monthly,
      :monthly_pattern => [occurrence],
      :start_date => Date.new(2011,1,1)})
    expected_dates = [[1,5], [2,2], [3,2], [4,6], [5,4], [6,1], [7,6], [8,3], [9,7], [10,5], [11,2], [12,7]]
    expected_dates.map! {|pair| Date.new(2011, *pair)}
    assert_equal expected_dates, schedule.occurrences_between(Date.new(2011,1,1), Date.new(2011,12,31))
    
    (0...(expected_dates.length - 1)).each do |i|
      assert_equal expected_dates[i+1], schedule.next_occurrence_after(expected_dates[i])
      assert_equal expected_dates[i], schedule.first_occurrence_before(expected_dates[i + 1])
    end
  end
  
  
  
  test "should not throw an exception when calculating monthly recurrence and skip causes a guess to be discarded" do
    schedule = Schedule.new({
      :kind => :monthly,
      :monthly_pattern => [
        [1, "Tuesday"],
        [2, "Thursday"],
        [3, "Thursday"],
        [3, "Tuesday"],
        [4, "Tuesday"],
        [5, "Thursday"] ],
      :skip => 3,
      :start_date => Date.new(2012,3,6),
      :end_date => Date.new(2012,3,29)})
    schedule.occurrences_between(schedule.start_date, schedule.end_date)
  end
  
  
  
  test "should not predict dates before the beginning of a schedule" do
    schedule = Schedule.new({
      :kind => :weekly,
      :weekly_pattern => %w{Monday},
      :start_date => Date.new(2011, 1, 3),
      :ends => true,
      :end_date => Date.new(2011, 1, 31)})
    assert_equal nil, schedule.first_occurrence_before(Date.new(2011,1,3))
    assert_equal nil, schedule.first_occurrence_on_or_before(Date.new(2011,1,2))
    assert_equal [], schedule.n_occurrences_before(10, Date.new(2011,1,3))
    assert_equal [], schedule.n_occurrences_on_or_before(10, Date.new(2011,1,2))
  end
  
  test "should not predict dates after the end of a schedule" do
    schedule = Schedule.new({
      :kind => :weekly,
      :weekly_pattern => %w{Monday},
      :start_date => Date.new(2011, 1, 3),
      :ends => true,
      :end_date => Date.new(2011, 1, 31)})
    assert_equal nil, schedule.first_occurrence_after(Date.new(2011,1,31))
    assert_equal nil, schedule.first_occurrence_on_or_after(Date.new(2011,2, 1))
    assert_equal [], schedule.occurrences_between(Date.new(2013, 9, 23), Date.new(2013, 9, 30))
  end
  
  
  
  test "all methods should take any kind of date as an argument" do
    schedule = Schedule.new({
      :kind => :weekly,
      :weekly_pattern => %w{Monday},
      :start_date => Date.new(2011, 1, 1),
      :ends => true,
      :end_date => Date.new(2011, 1, 31)})
    assert_equal Date.new(2011, 1, 17), schedule.first_occurrence_after(Time.new(2011, 1, 10))
    assert_equal Date.new(2011, 1, 3), schedule.first_occurrence_before(Time.new(2011, 1, 10))
  end
  
  
  
  def test_weekly_recurrence_and_skip
    schedule = Schedule.new({
      :kind => :weekly,
      :weekly_pattern => %w{Monday},
      :skip => 3,
      :start_date => Date.new(2011,1,1)}) # Saturday
    expected_dates = [[1,3], [1,24], [2,14], [3,7], [3,28]]
    expected_dates.map! {|pair| Date.new(2011, *pair)}
    assert_equal expected_dates, schedule.occurrences_between(Date.new(2011,1,1), Date.new(2011,3,31))
    
    (0...(expected_dates.length - 1)).each do |i|
      assert_equal expected_dates[i+1], schedule.next_occurrence_after(expected_dates[i])
      assert_equal expected_dates[i], schedule.first_occurrence_before(expected_dates[i + 1])
    end
  end
  
  
  
  def test_monthly_recurrence_and_skip
    schedule = Schedule.new({
      :kind => :monthly,
      :monthly_pattern => [[1, "Wednesday"]],
      :skip => 2,
      :start_date => Date.new(2011,1,1)})
    expected_dates = [[1,5], [3,2], [5,4], [7,6], [9,7], [11,2]]
    expected_dates.map! {|pair| Date.new(2011, *pair)}
    assert_equal expected_dates, schedule.occurrences_between(Date.new(2011,1,1), Date.new(2011,12,31))
    
    (0...(expected_dates.length - 1)).each do |i|
      assert_equal expected_dates[i+1], schedule.next_occurrence_after(expected_dates[i])
      assert_equal expected_dates[i], schedule.first_occurrence_before(expected_dates[i + 1])
    end
  end
  
  
  
  def test_annual_occurrences_during_month
    schedule = Schedule.new({
      :kind => :annually,
      :start_date => Date.new(1981,4,23)})
    dates = occurrences_during_month(schedule, 1981,4).map {|date| date.day}
    expected_dates = [23]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"
    
    dates = occurrences_during_month(schedule, 1972,4).map {|date| date.day}
    expected_dates = []
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"
    
    dates = occurrences_during_month(schedule, 1984,4).map {|date| date.day}
    expected_dates = [23]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"

    dates = occurrences_during_month(schedule, 1984,3).map {|date| date.day}
    expected_dates = []
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"

    dates = occurrences_during_month(schedule, 2009,12).map {|date| date.day}
    expected_dates = []
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"
  end
  
  test "When there is no 5th weekday of a month, schedule shouldn't crash" do
    start = Date.new(2010,6,1)
    schedule = Schedule.new({
      :kind => :monthly,
      :monthly_pattern => [[5, "Monday"]],
      :start_date => start})
    assert_equal "The fifth Monday of every month", schedule.humanize
    
    # There are not 5 Mondays during June 2010
    assert_nothing_raised do
      assert_equal [], occurrences_during_month(schedule, 2010, 6)
    end
    
    next_fifth_month = Date.new(2010,8,30)
    assert_equal next_fifth_month, schedule.first_occurrence_on_or_after(start)
  end
  
  
  
  def test_first_occurrence_on_or_after
    fifth_sunday = Date.new(2010, 8, 29)
    schedule = Schedule.new({
      :kind => :monthly,
      :monthly_pattern => [[5, "Sunday"]],
      :start_date => fifth_sunday})
    assert_equal "The fifth Sunday of every month", schedule.humanize
    
    assert_equal fifth_sunday, schedule.first_occurrence_on_or_after(fifth_sunday)
    assert schedule.contains?(fifth_sunday)
  end
  
  
  
  def test_february_29
    schedule = Schedule.new({
      :kind => :annually,
      :start_date => Date.new(2008, 2, 29)
    });
    
    assert_equal [Date.new(2010, 2, 28)], occurrences_during_month(schedule, 2010, 2)
    assert_equal [Date.new(2012, 2, 29)], occurrences_during_month(schedule, 2012, 2)
  end
  
  
  
  def test_recurs_on31st
    schedule = Schedule.new({
      :kind => :monthly,
      :monthly_pattern => [31],
      :start_date => Date.new(2008, 2, 29)
    })
    
    assert_equal [Date.new(2010, 1, 31)], occurrences_during_month(schedule, 2010, 1)
    assert_equal [], occurrences_during_month(schedule, 2010, 2)
  end
  
  
  
  if ENV['PERFORMANCE_TEST']
    test "performance test" do
      n = 1000
      
      # Each of these schedules should describe 52 events
      
      Benchmark.bm(20) do |x|
        x.report("weekly (simple):") do
          n.times do 
            Schedule.new(
              :kind => :weekly,
              :weekly_pattern => ["Friday"],
              :start_date => Date.new(2009, 1, 1)) \
              .occurrences_between(Date.new(2009, 1, 1), Date.new(2009, 12, 31))
          end
        end
        x.report("weekly (complex):") do
          n.times do 
            Schedule.new(
              :kind => :weekly,
              :weekly_pattern => ["Monday", "Wednesday", "Friday"],
              :start_date => Date.new(2009, 1, 1)) \
              .occurrences_between(Date.new(2009, 1, 1), Date.new(2009, 5, 2))
          end
        end
        x.report("monthly (simple):") do
          n.times do
            Schedule.new(
              :kind => :monthly,
              :monthly_pattern => [[2, "Monday"]],
              :start_date => Date.new(2009, 1, 1)) \
              .occurrences_between(Date.new(2009, 1, 1), Date.new(2013, 4, 30))
          end
        end
        x.report("monthly (complex):") do
          n.times do
            Schedule.new(
              :kind => :monthly,
              :monthly_pattern => [[2, "Monday"], [4, "Monday"]],
              :start_date => Date.new(2009, 1, 1)) \
              .occurrences_between(Date.new(2009, 1, 1), Date.new(2011, 3, 1))
          end
        end
        x.report("yearly:") do
          n.times do
            Schedule.new(
              :kind => :annually,
              :start_date => Date.new(1960, 3, 15)) \
              .occurrences_between(Date.new(1960, 1, 1), Date.new(2011, 12, 31))
          end
        end
        x.report("yearly (2/29):") do
          n.times do
            Schedule.new(
              :kind => :annually,
              :start_date => Date.new(1960, 2, 29)) \
              .occurrences_between(Date.new(1960, 1, 1), Date.new(2011, 12, 31))
          end
        end
      end
      
    end
  end
  
  
  
private
  
  
  
  def occurrences_during_month(schedule, year, month)
    date1 = Date.new(year, month, 1)
    date2 = Date.new(year, month, -1)
    schedule.occurrences_between(date1, date2)
  end
  
  
  
end
