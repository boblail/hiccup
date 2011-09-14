# encoding: UTF-8
require "test_helper"


class IcalSerializableTest < ActiveSupport::TestCase
  include Hiccup
  
  
  def self.test_roundtrip(*args)
    message = args.shift
    ics = args.shift
    attributes = args.shift
    recurrence = Schedule.new(attributes)
    test(message) do
      assert_roundtrip ics, recurrence
    end
  end
  
  
  test_roundtrip(
    "Simple weekly recurrence",
    "DTSTART;VALUE=DATE-TIME:20090101T000000Z\nRRULE:FREQ=WEEKLY;BYDAY=SU\n",
    { :kind => :weekly,
      :weekly_pattern => %w{Sunday},
      :start_date => DateTime.new(2009, 1, 1)
    })
  
  
  test_roundtrip(
    "Complex weekly recurrence (with an interval)",
    "DTSTART;VALUE=DATE-TIME:20090101T000000Z\nRRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=TU,TH\n",
    { :kind => :weekly,
      :weekly_pattern => %w{Tuesday Thursday},
      :start_date => DateTime.new(2009, 1, 1),
      :skip => 2
    })
  
  
  test_roundtrip(
    "Simple annual recurrence",
    "DTSTART;VALUE=DATE-TIME:20090315T000000Z\nRRULE:FREQ=YEARLY\n",
    { :kind => :annually,
      :start_date => DateTime.new(2009, 3, 15)
    })
  
  
  test_roundtrip(
    "Annual recurrence with an end date",
    "DTSTART;VALUE=DATE-TIME:20090315T000000Z\nRRULE:FREQ=YEARLY;UNTIL=20120315T000000Z\n",
    { :kind => :annually,
      :start_date => DateTime.new(2009, 3, 15),
      :end_date => DateTime.new(2012, 3, 15), :ends => true
    })
  
  
  test_roundtrip(
    "Simple monthly recurrence",
    "DTSTART;VALUE=DATE-TIME:20090315T000000Z\nRRULE:FREQ=MONTHLY;BYMONTHDAY=4\n",
    { :kind => :monthly,
      :monthly_pattern => [4],
      :start_date => DateTime.new(2009, 3, 15)
    })
  
  
  test_roundtrip(
    "Monthly recurrence on the last Tuesday of the month",
    "DTSTART;VALUE=DATE-TIME:20090315T000000Z\nRRULE:FREQ=MONTHLY;BYDAY=-1TU\n",
    { :kind => :monthly,
      :monthly_pattern => [[-1, "Tuesday"]],
      :start_date => DateTime.new(2009, 3, 15)
    })
  
  
  test_roundtrip(
    "Complex monthly recurrence",
    "DTSTART;VALUE=DATE-TIME:20090315T000000Z\nRRULE:FREQ=MONTHLY;BYDAY=2SU,4SU\n",
    { :kind => :monthly,
      :monthly_pattern => [[2, "Sunday"], [4, "Sunday"]],
      :start_date => DateTime.new(2009, 3, 15)
    })
  
  
protected
  
  
  def assert_roundtrip(ics, recurrence)
    assert_equal ics, recurrence.to_ical, "to_ical did not result in the expected ICS"
    assert_equal recurrence.to_hash, Schedule.from_ical(ics).to_hash, "from_ical did not result in the expected recurrence"
  end
  
  
end
