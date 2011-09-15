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
    "The first Monday of every month",
    {:kind => :monthly, :monthly_pattern => [[1, "Monday"]]})
    
  test_humanize(
    "The last Tuesday of every month",
    {:kind => :monthly, :monthly_pattern => [[-1, "Tuesday"]]})
    
  test_humanize(
    "The first Monday and third Monday of every other month",
    {:kind => :monthly, :monthly_pattern => [[1, "Monday"], [3, "Monday"]], :skip => 2})
    
  test_humanize(
    "Every year on #{Date.today.strftime('%B %d')}",
    {:kind => :annually})
    
  test_humanize(
    "Every other year on #{Date.today.strftime('%B %d')}",
    {:kind => :annually, :skip => 2})
    
  test_humanize(
    "Every fourth year on #{Date.today.strftime('%B %d')}",
    {:kind => :annually, :skip => 4})
  
  
  
end
