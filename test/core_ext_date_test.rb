require "test_helper"


class CoreExtDateTest < ActiveSupport::TestCase


  should "correctly identify the nth weekday of the month of a date" do
    assert_equal 1, Date.new(2012, 7, 1).get_nth_wday_of_month
    assert_equal 1, Date.new(2012, 7, 7).get_nth_wday_of_month
    assert_equal 2, Date.new(2012, 7, 8).get_nth_wday_of_month
    assert_equal 2, Date.new(2012, 7, 14).get_nth_wday_of_month
    assert_equal 3, Date.new(2012, 7, 15).get_nth_wday_of_month
    assert_equal 3, Date.new(2012, 7, 21).get_nth_wday_of_month
    assert_equal 4, Date.new(2012, 7, 22).get_nth_wday_of_month
    assert_equal 4, Date.new(2012, 7, 28).get_nth_wday_of_month
    assert_equal 5, Date.new(2012, 7, 29).get_nth_wday_of_month
  end

  should "correctly identify the nth weekday of the month of a date as a string" do
    assert_equal "1 Sunday", Date.new(2012, 7, 1).get_nth_wday_string
    assert_equal "1 Saturday", Date.new(2012, 7, 7).get_nth_wday_string
    assert_equal "2 Sunday", Date.new(2012, 7, 8).get_nth_wday_string
    assert_equal "2 Saturday", Date.new(2012, 7, 14).get_nth_wday_string
    assert_equal "3 Sunday", Date.new(2012, 7, 15).get_nth_wday_string
    assert_equal "3 Saturday", Date.new(2012, 7, 21).get_nth_wday_string
    assert_equal "4 Sunday", Date.new(2012, 7, 22).get_nth_wday_string
    assert_equal "4 Saturday", Date.new(2012, 7, 28).get_nth_wday_string
    assert_equal "5 Sunday", Date.new(2012, 7, 29).get_nth_wday_string
  end


end
