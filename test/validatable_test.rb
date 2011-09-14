require "test_helper"


class ValidatableTest < ActiveSupport::TestCase
  include Hiccup
  
  
  
  def test_invalid_recurrence
    # Test nil weekly recurrence
    r = Schedule.new(:kind => :weekly)
    assert !r.valid?,                                   "Recurrence should be invalid: weekly_pattern is empty"
    assert r.errors[:weekly_pattern].any?,              "weekly_pattern should be invalid if empty and kind is 'weekly'"
    
    # Test nil monthly recurrence
    r = Schedule.new(:kind => :monthly)
    assert !r.valid?,                                   "Recurrence should be invalid: monthly_pattern is empty"
    assert r.errors[:monthly_pattern].any?,             "monthly_pattern should be invalid if empty and kind is 'monthly'"
    
    # Test invalid monthly recurrence
    r = Schedule.new(:kind => :monthly, :monthly_pattern => [[2, "holiday"]])
    assert !r.valid?,                                   "Recurrence should be invalid: monthly_pattern is invalid"
    assert r.errors[:monthly_pattern].any?,             "monthly_pattern should be invalid: 'holiday' is not a valid MonthlyOccurrenceType"
  end
  
  
  
  def test_temporal_paradoxes
    recurrence = Schedule.new({
      :kind => :annually,
      :ends => true,
      :start_date => Date.today,
      :end_date => 5.years.since(Date.today).to_date
    })
    assert_valid(recurrence)
    recurrence = Schedule.new({
      :kind => :annually,
      :ends => true,
      :start_date => Date.today,
      :end_date => -5.years.since(Date.today).to_date
    })
    assert !recurrence.valid?,                          "Recurrence should be invalid: its recurrence ends before it starts"
  end
  
  
  
  def test_valid_weekly_recurrence
    recurrence = Schedule.new(:kind => :weekly, :weekly_pattern => %w{Tuesday})
    assert_valid(recurrence)
  end
  
  
  
  def test_valid_monthly_recurrence
    recurrence = Schedule.new(:kind => :monthly, :monthly_pattern => [2])
    assert_valid(recurrence)
    
    recurrence = Schedule.new(:kind => :monthly, :monthly_pattern => [[2, "Thursday"]])
    assert_valid(recurrence)
  end
  
  
  
  def test_valid_annual_recurrence
    recurrence = Schedule.new(:kind => :annually)
    assert_valid(recurrence)
  end
  
  
  
private
  
  
  
  def assert_valid(record)
    assert record.valid?, record.errors.inspect
  end
  
  
  
end