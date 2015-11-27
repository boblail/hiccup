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

    context "when enumerating from a date in a skipped month" do
      should "skip months from the schedule's start date not from the offset" do
        date = Date.new(2015, 2, 1)
        enumerator = @schedule.enumerator.new(@schedule, date)
        assert_equal Date.new(2015, 3, 5), enumerator.next
      end
    end

    context "when enumerating forward from a date toward the end of a skipped month" do
      should "find the first date from the start of an unskipped month" do
        date = Date.new(2015, 4, 30)
        enumerator = @schedule.enumerator.new(@schedule, date)
        assert_equal Date.new(2015, 5, 7), enumerator.next
      end
    end

    context "when enumerating backward from a date toward the beginning of a skipped month" do
      should "find the first date from the end of an unskipped month" do
        date = Date.new(2015, 6, 1)
        enumerator = @schedule.enumerator.new(@schedule, date)
        assert_equal Date.new(2015, 5, 7), enumerator.prev
      end
    end
  end


  context "last of the month" do
    should "return the last day of the month" do
      date = Date.new(2014, 12, 31)
      @schedule = Schedule.new(
        kind: :monthly,
        monthly_pattern: [-1],
        start_date: date
      )
      enumerator = @schedule.enumerator.new(@schedule, date)
      assert_equal Date.new(2015, 1, 31), enumerator.next
      assert_equal Date.new(2015, 2, 28), enumerator.next
      assert_equal Date.new(2015, 3, 31), enumerator.next
    end

    should "return the last sunday of the month" do
      date = Date.new(2014, 12, 31)
      @schedule = Schedule.new(
        kind: :monthly,
        monthly_pattern: [[-1, "Sunday"]],
        start_date: date
      )
      enumerator = @schedule.enumerator.new(@schedule, date)
      assert_equal Date.new(2015, 1, 25), enumerator.next
    end

    should "return the last monday of the month" do
      date = Date.new(2014, 12, 31)
      @schedule = Schedule.new(
        kind: :monthly,
        monthly_pattern: [[-1, "Monday"]],
        start_date: date
      )
      enumerator = @schedule.enumerator.new(@schedule, Date.new(2015, 2, 28))
      assert_equal Date.new(2015, 3, 30), enumerator.next
    end

    should "return the last tuesday of the month" do
      date = Date.new(2014, 12, 31)
      @schedule = Schedule.new(
        kind: :monthly,
        monthly_pattern: [[-1, "Tuesday"]],
        start_date: date
      )
      enumerator = @schedule.enumerator.new(@schedule, Date.new(2015, 1, 31))
      assert_equal Date.new(2015, 2, 24), enumerator.next
    end

    should "return the second to last tuesday of the month" do
      date = Date.new(2014, 12, 31)
      @schedule = Schedule.new(
        kind: :monthly,
        monthly_pattern: [[-2, "Tuesday"]],
        start_date: date
      )
      enumerator = @schedule.enumerator.new(@schedule, Date.new(2015, 2, 28))
      assert_equal Date.new(2015, 2, 17), enumerator.prev
    end
  end

  context "with an empty schedule" do
    setup do
      @schedule = Schedule.new(
        kind: :monthly,
        skip: 2,
        monthly_pattern: [],
        start_date: Date.new(2015, 1, 1))
    end

    should "always return nil" do
      date = Date.new(2015, 2, 1)
      enumerator = @schedule.enumerator.new(@schedule, date)
      assert_equal nil, enumerator.next
    end
  end


end
