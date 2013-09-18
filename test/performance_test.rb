require "test_helper"
require "benchmark"

class PerformanceTest < ActiveSupport::TestCase
  include Hiccup
  
  
  { 100 => 50,
    500 => 50,
   1000 => 50 }.each do |number, expected_duration|
    test "should generated guesses from #{number} dates in under #{expected_duration}ms" do
      guesser = Hiccup::Inferable::Guesser.new(Hiccup::Schedule)
      dates = (0...number).map { |i| Date.new(2010, 1, 1) + i.week }
      duration = Benchmark.ms { guesser.generate_guesses(dates) }
      # puts "\e[33m\e[1m#{number}\e[0m\e[33m dates took \e[1m%.2fms\e[0m" % duration
      assert duration <= expected_duration, "It took %.2fms" % duration
    end
  end
  
  
  # Inferring 500 dates still takes 10 seconds.
  # It spends 7.3 of those seconds predicting dates,
  # 6.9 of those predicting monthly or weekly dates. 
  { 10 =>  0.1.seconds,
    50 =>  0.5.seconds,
   100 =>  1.0.seconds }.each do |number, expected_duration|
    test "should infer a schedule from #{number} dates in under #{expected_duration} second(s)" do
      dates = (0...number).map { |i| Date.new(2010, 1, 1) + i.week }
      duration = Benchmark.ms { Schedule.infer(dates, verbosity: 0) } / 1000
      assert duration <= expected_duration, "It took %.2f seconds" % duration
    end
  end
  
  
end
