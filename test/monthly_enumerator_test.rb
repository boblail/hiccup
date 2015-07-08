require "test_helper"


class MonthlyEnumeratorTest < ActiveSupport::TestCase
  include Hiccup
  
  
  context "with a complex schedule" do
    setup do
      @schedule = Schedule.new({
        :kind => :monthly,
        :monthly_pattern => [
          [1, "Sunday"],
          [2, "Saturday"],
          [2, "Sunday"],
          [3, "Sunday"],
          [4, "Saturday"],
          [4, "Sunday"],
          [5, "Sunday"] ],
        start_date: Date.new(2005, 1, 8)
      })
    end
    
    context "when enumerating backward" do
      should "return the most-recent date prior to the start_date, NOT the earliest date in the month" do
        # Start with a date in the middle of the month
        # More than one date prior to the seed date, yet
        # after the first of the month.
        date = Date.new(2013, 10, 15)
        enumerator = @schedule.enumerator.new(@schedule, date)
        assert_equal Date.new(2013, 10, 13), enumerator.prev
      end
    end
  end
  
  
  context "with a schedule that skips" do
    setup do
      @schedule = Schedule.new(
        kind: :monthly,
        skip: 2,
        monthly_pattern: [[1, "Thursday"]],
        start_date: Date.new(2015, 1, 1))
    end
    
    context "when enumerating from the start date" do
      should "skip months from the schedule's start date" do
        assert_equal [Date.new(2015, 1, 1), Date.new(2015, 3, 5), Date.new(2015, 5, 7)],
                     @schedule.occurrences_between(Date.new(2015, 1, 1), Date.new(2015, 5, 31))
      end
    end
    
    context "when enumerating from an offset" do
      should "skip months from the schedule's start date not from the offset" do
        assert_equal [Date.new(2015, 3, 5), Date.new(2015, 5, 7)],
                     @schedule.occurrences_between(Date.new(2015, 2, 1), Date.new(2015, 6, 30))
      end
    end
  end
  
  
end
