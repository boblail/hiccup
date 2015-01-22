require "test_helper"


class HumanizableTest < ActiveSupport::TestCase
  include Hiccup
  
  
  def self.test_humanize(*args)
    expected_string = args.shift
    attributes = args.shift
    
    test(expected_string) do
      schedule = Schedule.new(attributes)
      assert_equal expected_string, schedule.humanize
    end
  end
  
  
  
  test_humanize(
    "Every Sunday",
    {:kind => :weekly, :weekly_pattern => %w[Sunday]})
    
  test_humanize(
    "Every other Sunday",
    {:kind => :weekly, :weekly_pattern => %w[Sunday], :skip => 2})
    
  test_humanize(
    "Every Sunday and Monday",
    {:kind => :weekly, :weekly_pattern => %w[Sunday Monday]})
    
  test_humanize(
    "Monday, Wednesday, and Friday of every third week",
    {:kind => :weekly, :weekly_pattern => %w[Monday Wednesday Friday], :skip => 3})
    
  test_humanize(
    "The 4th of every month",
    {:kind => :monthly, :monthly_pattern => [4]})
    
  test_humanize(
    "The 4th and 5th of every month",
    {:kind => :monthly, :monthly_pattern => [4,5]})
    
  test_humanize(
    "The last day of every month",
    {:kind => :monthly, :monthly_pattern => [-1]})

  test_humanize(
    "The first Monday of every month",
    {:kind => :monthly, :monthly_pattern => [[1, "Monday"]]})
    
  test_humanize(
    "The last Tuesday of every month",
    {:kind => :monthly, :monthly_pattern => [[-1, "Tuesday"]]})
    
  test_humanize(
    "The first Monday and third Monday of every other month",
    {:kind => :monthly, :monthly_pattern => [[1, "Monday"], [3, "Monday"]], :skip => 2})
    
  test_humanize(
    "Every year on October 1",
    {:kind => :annually, start_date: Date.new(2012, 10, 1)})
    
  test_humanize(
    "Every year on October 10",
    {:kind => :annually, start_date: Date.new(2012, 10, 10)})
    
  test_humanize(
    "Every other year on August 12",
    {:kind => :annually, :skip => 2, start_date: Date.new(2012, 8, 12)})
    
  test_humanize(
    "Every fourth year on January 31",
    {:kind => :annually, :skip => 4, start_date: Date.new(1888, 1, 31)})
  
  
  
  test "should not have spaces in front of day numbers" do
    independence_day = Schedule.new({
      :kind => :annually,
      :start_date => Date.new(2012, 7, 4)
    })
    assert_equal "Every year on July 4", independence_day.humanize
  end
  
  
  
end
