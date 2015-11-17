require "test_helper"


class WeeklyEnumeratorTest < ActiveSupport::TestCase
  include Hiccup



  test "should generate a cycle of [7] for something that occurs every week on one day" do
    assert_equal [7], cycle_for(
      :start_date => Date.new(2013, 9, 23),
      :weekly_pattern => ["Monday"])
  end

  test "should generate a cycle of [21] for something that occurs every _third_ week on one day" do
    assert_equal [21], cycle_for(
      :start_date => Date.new(2013, 9, 23),
      :weekly_pattern => ["Monday"],
      :skip => 3)
  end



  test "should generate a cycle of [6, 8] for something that occurs every other Saturday and Sunday when the start date is a Sunday" do
    assert_equal [6, 8], cycle_for(
      :start_date => Date.new(2013, 9, 22),
      :weekly_pattern => ["Saturday", "Sunday"],
      :skip => 2)
  end

  test "should generate a cycle of [8, 6] for something that occurs every other Saturday and Sunday when the start date is a Saturday" do
    assert_equal [8, 6], cycle_for(
      :start_date => Date.new(2013, 9, 28),
      :weekly_pattern => ["Saturday", "Sunday"],
      :skip => 2)
  end



  test "should generate a cycle of [2, 2, 10] for something that occurs every other Monday, Wednesday, Friday when the start date is a Monday" do
    assert_equal [2, 2, 10], cycle_for(
      :start_date => Date.new(2013, 9, 23),
      :weekly_pattern => ["Monday", "Wednesday", "Friday"],
      :skip => 2)
  end

  test "should generate a cycle of [2, 10, 2] for something that occurs every other Monday, Wednesday, Friday when the start date is a Wednesday" do
    assert_equal [2, 10, 2], cycle_for(
      :start_date => Date.new(2013, 9, 25),
      :weekly_pattern => ["Monday", "Wednesday", "Friday"],
      :skip => 2)
  end

  test "should generate a cycle of [10, 2, 2] for something that occurs every other Monday, Wednesday, Friday when the start date is a Friday" do
    assert_equal [10, 2, 2], cycle_for(
      :start_date => Date.new(2013, 9, 27),
      :weekly_pattern => ["Monday", "Wednesday", "Friday"],
      :skip => 2)
  end



  test "should generate a cycle of [2, 5] for something that occurs every Tuesday and Thursday when the start date is a Friday" do
    assert_equal [2, 5], cycle_for(
      :start_date => Date.new(2013, 9, 27),
      :weekly_pattern => ["Tuesday", "Thursday"])
  end



  context "#position_of" do
    setup do
      @schedule = Schedule.new(
        :kind => :weekly,
        :start_date => Date.new(2013, 9, 26), # Thursday
        :weekly_pattern => ["Tuesday", "Thursday", "Friday"],
        :skip => 2)
    end

    should "be a sane test" do
      assert_equal [1, 11, 2], cycle_for(@schedule)
    end

    should "find the correct position for the given date" do
      assert_equal 0,   position_of(@schedule, 2013, 9, 26)
      assert_equal 1,   position_of(@schedule, 2013, 9, 27)
      assert_equal 2,   position_of(@schedule, 2013, 10, 8)
      assert_equal 0,   position_of(@schedule, 2013, 10, 10)
      assert_equal 1,   position_of(@schedule, 2013, 10, 11)
      assert_equal 2,   position_of(@schedule, 2013, 10, 22)
    end
  end



  context "with a complex schedule" do
    setup do
      @schedule = Schedule.new(
        :kind => :weekly,
        :start_date => Date.new(2013, 9, 26), # Thursday
        :weekly_pattern => ["Tuesday", "Thursday", "Friday"])
    end

    should "pick the right date when enumerating backward" do
      enumerator = @schedule.enumerator.new(@schedule, Date.new(2013, 10, 16)) # Wednesday!
      assert_equal Date.new(2013, 10, 15), enumerator.prev
    end
  end



  context "Given an invalid schedule with no weekly pattern, it" do
    setup do
      @schedule = Schedule.new(
        :kind => :weekly,
        :start_date => Date.new(2013, 9, 26),
        :weekly_pattern => [])
    end

    should "return nil for prev rather than raising an exception" do
      enumerator = @schedule.enumerator.new(@schedule, Date.today)
      assert_equal nil, enumerator.prev
    end

    should "return nil for next rather than raising an exception" do
      enumerator = @schedule.enumerator.new(@schedule, Date.today)
      assert_equal nil, enumerator.next
    end
  end



private

  def cycle_for(options={})
    schedule = build_schedule(options)
    enumerator = schedule.enumerator.new(schedule, Date.today)
    enumerator.send :calculate_cycle, schedule
  end

  def position_of(schedule, *args)
    date = build_date(*args)
    enumerator = schedule.enumerator.new(schedule, date)
    enumerator.send :position_of, date
  end

  def build_schedule(options={})
    return options if options.is_a? Schedule
    Schedule.new(options.merge(:kind => :weekly))
  end

  def build_date(*args)
    return Date.new(*args) if args.length == 3
    args.first
  end

end
