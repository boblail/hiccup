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
  
  
  
  def test_occurs_on_weekly
    schedule = Schedule.new({
      :kind => :weekly,
      :pattern => %w{Monday Wednesday Friday},
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
      :pattern => %w{Monday Wednesday Friday},
      :start_date => Date.new(2009,3,15),
      :ends => true,
      :end_date => Date.new(2009,11,30)})
    dates = schedule.occurrences_during_month(2009,7).map {|date| date.day}
    expected_dates = [1,3,6,8,10,13,15,17,20,22,24,27,29,31]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for weekly schedule"
    
    dates = schedule.occurrences_during_month(2008,7).map {|date| date.day}
    expected_dates = []
    assert_equal expected_dates, dates,                 "occurrences_during_month should generate no occurrences if before start_date"

    schedule = Schedule.new({
      :kind => :weekly,
      :pattern => %w{Monday},
      :start_date => Date.new(2010,6,14),
      :ends => true,
      :end_date => Date.new(2010,6,21)})
    dates = schedule.occurrences_during_month(2010,6).map {|date| date.day}
    expected_dates = [14,21]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not correctly observe end date for weekly schedule"
  end
  
  
  
  def test_monthly_occurrences_during_month
    schedule = Schedule.new({
      :kind => :monthly,
      :pattern => [[2, "Sunday"], [4, "Sunday"]],
      :start_date => Date.new(2004,3,15)})
    dates = schedule.occurrences_during_month(2009,12).map {|date| date.day}
    expected_dates = [13,27]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for monthly schedule"
    
    dates = schedule.occurrences_during_month(2009,2).map {|date| date.day}
    expected_dates = [8,22]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for monthly schedule"
    
    dates = schedule.occurrences_during_month(1991,7).map {|date| date.day}
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
      :pattern => [occurrence],
      :start_date => Date.new(2011,1,1)})
    expected_dates = [[1,5], [2,2], [3,2], [4,6], [5,4], [6,1], [7,6], [8,3], [9,7], [10,5], [11,2], [12,7]]
    expected_dates.map! {|pair| Date.new(2011, *pair)}
    assert_equal expected_dates, schedule.occurrences_between(Date.new(2011,1,1), Date.new(2011,12,31))
    
    (0...(expected_dates.length - 1)).each do |i|
      assert_equal expected_dates[i+1], schedule.next_occurrence_after(expected_dates[i])
      assert_equal expected_dates[i], schedule.first_occurrence_before(expected_dates[i + 1])
    end
  end
  
  
  
  def test_weekly_recurrence_and_skip
    schedule = Schedule.new({
      :kind => :weekly,
      :pattern => ["Monday"],
      :skip => 3,
      :start_date => Date.new(2011,1,1)})
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
      :pattern => [[1, "Wednesday"]],
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
    dates = schedule.occurrences_during_month(1981,4).map {|date| date.day}
    expected_dates = [23]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"
    
    dates = schedule.occurrences_during_month(1972,4).map {|date| date.day}
    expected_dates = []
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"
    
    dates = schedule.occurrences_during_month(1984,4).map {|date| date.day}
    expected_dates = [23]
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"

    dates = schedule.occurrences_during_month(1984,3).map {|date| date.day}
    expected_dates = []
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"

    dates = schedule.occurrences_during_month(2009,12).map {|date| date.day}
    expected_dates = []
    assert_equal expected_dates, dates,                 "occurrences_during_month did not generate expected dates for annual schedule"
  end
  
  test "When there is no 5th weekday of a month, schedule shouldn't crash" do
    start = Date.new(2010,6,1)
    schedule = Schedule.new({
      :kind => :monthly,
      :pattern => [[5, "Monday"]],
      :start_date => start})
    assert_equal "The fifth Monday of every month", schedule.humanize
    
    # There are not 5 Mondays during June 2010
    assert_nothing_raised do
      assert_equal [], schedule.occurrences_during_month(2010, 6)
    end
    
    next_fifth_month = Date.new(2010,8,30)
    assert_equal next_fifth_month, schedule.first_occurrence_on_or_after(start)
  end
  
  
  
  def test_first_occurrence_on_or_after
    fifth_sunday = Date.new(2010, 8, 29)
    schedule = Schedule.new({
      :kind => :monthly,
      :pattern => [[5, "Sunday"]],
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
    
    assert_equal [Date.new(2010, 2, 28)], schedule.occurrences_during_month(2010, 2)
  end
  
  
  
  def test_recurs_on31st
    schedule = Schedule.new({
      :kind => :monthly,
      :pattern => [31],
      :start_date => Date.new(2008, 2, 29)
    });
    
    assert_equal [Date.new(2010, 1, 31)], schedule.occurrences_during_month(2010, 1)
    assert_equal [], schedule.occurrences_during_month(2010, 2)
  end
  
  
  
  # def test_monthly_occurrence_to_date
  #   occurrence = MonthlyOccurrence.new(:ordinal => 3, :kind => "Thursday")
  #   assert_equal 21, occurrence.to_date(2009, 5).day,   "The third Thursday in May 2009 should be the 21st"
  #   assert_equal 16, occurrence.to_date(2009, 4).day,   "The third Thursday in April 2009 should be the 16th"
  #   assert_equal 15, occurrence.to_date(2012, 11).day,  "The third Thursday in November 2012 should be the 15th"
  #   
  #   occurrence = MonthlyOccurrence.new(:ordinal => 1, :kind => "Tuesday")
  #   assert_equal 5, occurrence.to_date(2009, 5).day,    "The first Tuesday in May 2009 should be the 5th"
  #   assert_equal 2, occurrence.to_date(2008, 12).day,   "The first Tuesday in December 2008 should be the 2nd"
  #   assert_equal 1, occurrence.to_date(2009, 9).day,    "The first Tuesday in September 2009 should be the 1st"
  #   
  #   occurrence = MonthlyOccurrence.new(:ordinal => 1, :kind => "Sunday")
  #   assert_equal 3, occurrence.to_date(2009, 5).day,    "The first Sunday in May 2009 should be the 3rd"
  #   assert_equal 1, occurrence.to_date(2010, 8).day,    "The first Sunday in August 2010 should be the 1st"
  #   assert_equal 7, occurrence.to_date(2009, 6).day,    "The first Sunday in June 2009 should be the 7th"
  #   
  #   occurrence = MonthlyOccurrence.new(:ordinal => 1, :kind => "day")
  #   assert_equal 1, occurrence.to_date(2009, 5).day,    "The first of May 2009 should be 1"
  #   
  #   occurrence = MonthlyOccurrence.new(:ordinal => 22, :kind => "day")
  #   assert_equal 22, occurrence.to_date(2009, 5).day,   "The twenty-second of May 2009 should be 22"
  #   
  #   #occurrence = MonthlyOccurrence.new(:ordinal => -1, :kind => "Sunday")
  #   #assert_equal 31, occurrence.to_date(2009, 5),       "The last Sunday in May 2009 should be the 31st"
  # end
  #
  #
  # test "to_date should return nil if there is no occurrence with the specified parameters" do
  #   mo = MonthlyOccurrence.new(:ordinal => 5, :kind => "Monday")
  #   assert_equal "fifth Monday", mo.to_s
  #   assert_nil mo.to_date(2010, 6)
  # end
  
  
  
end
