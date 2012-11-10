require "test_helper"
require "hiccup/core_ext/duration"


class DurationExtTest < ActiveSupport::TestCase
  
  
  def test_active_support_duration_is_working
    assert 1.day.is_a?(ActiveSupport::Duration), "I ran into a problem where the Ruby gem 'god' also added :day to Fixnum and broke ActiveSupport."
  end
  
  
  def test_after_alias
    t = 17.weeks.ago
    [:day, :week, :month, :year].each do |period|
      assert_equal 1.send(period).since(t), 1.send(period).after(t)
    end
  end
  
  
  def test_before_alias
    t = 17.weeks.ago
    [:day, :week, :month, :year].each do |period|
      assert_equal 1.send(period).ago(t), 1.send(period).before(t)
    end
  end
  
  
end
