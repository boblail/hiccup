require 'active_support/concern'
require 'active_support/core_ext/date/conversions'
require 'hiccup/core_ext/enumerable'
require 'hiccup/core_ext/hash'


module Hiccup
  module Inferrable
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      
      
      def infer(dates, options={})
        @verbose = options.fetch(:verbose, false)
        dates = extract_array_of_dates!(dates)
        guesses = generate_guesses(dates)
        guess, score = pick_best_guess(guesses, dates)
        guess
      end
      
      
      
      def generate_guesses(dates)
        @start_date = dates.min
        @end_date = dates.max
        [].tap do |guesses|
          guesses.concat generate_yearly_guesses(dates)
          guesses.concat generate_monthly_guesses(dates)
          guesses.concat generate_weekly_guesses(dates)
        end
      end
      
      def generate_yearly_guesses(dates)
        histogram_of_patterns = dates.to_histogram do |date|
          [date.month, date.day]
        end
        patterns_by_popularity = histogram_of_patterns.flip # => {1 => [...], 2 => [...], 5 => [a, b]}
        highest_popularity = patterns_by_popularity.keys.max # => 5
        most_popular = patterns_by_popularity[highest_popularity].first # => a
        start_date = Date.new(@start_date.year, *most_popular)

        [].tap do |guesses|
          (1...5).each do |skip|
            guesses << self.new.tap do |schedule|
              schedule.kind = :annually
              schedule.start_date = start_date
              schedule.end_date = @end_date
              schedule.skip = skip
            end
          end
        end
      end
      
      def generate_monthly_guesses(dates)
        histogram_of_patterns = dates.to_histogram do |date|
          [date.get_nth_wday_of_month, Date::DAYNAMES[date.wday]]
        end
        patterns_by_popularity = histogram_of_patterns.flip
        
        histogram_of_days = dates.to_histogram(&:day)
        days_by_popularity = histogram_of_days.flip
        
        if @verbose
          puts "",
               "  monthly analysis:",
               "    input: #{dates.inspect}",
               "    histogram (weekday): #{histogram_of_patterns.inspect}",
               "    by_popularity (weekday): #{patterns_by_popularity.inspect}",
               "    histogram (day): #{histogram_of_days.inspect}",
               "    by_popularity (day): #{days_by_popularity.inspect}"
        end
        
        [].tap do |guesses|
          (1...5).each do |skip|
            enumerate_by_popularity(days_by_popularity) do |days|
              guesses << self.new.tap do |schedule|
                schedule.kind = :monthly
                schedule.start_date = @start_date
                schedule.end_date = @end_date
                schedule.skip = skip
                schedule.monthly_pattern = days
              end
            end
            
            enumerate_by_popularity(patterns_by_popularity) do |patterns|
              guesses << self.new.tap do |schedule|
                schedule.kind = :monthly
                schedule.start_date = @start_date
                schedule.end_date = @end_date
                schedule.skip = skip
                schedule.monthly_pattern = patterns
              end
            end
          end
        end
      end
      
      def generate_weekly_guesses(dates)
        [].tap do |guesses|
          histogram_of_wdays = dates.to_histogram do |date|
            Date::DAYNAMES[date.wday]
          end
          wdays_by_popularity = histogram_of_wdays.flip
          
          if @verbose
            puts "",
                 "  weekly analysis:",
                 "    input: #{dates.inspect}",
                 "    histogram: #{histogram_of_wdays.inspect}",
                 "    by_popularity: #{wdays_by_popularity.inspect}"
          end
          
          (1...5).each do |skip|
            enumerate_by_popularity(wdays_by_popularity) do |wdays|
              guesses << self.new.tap do |schedule|
                schedule.kind = :weekly
                schedule.start_date = @start_date
                schedule.end_date = @end_date
                schedule.skip = skip
                schedule.weekly_pattern = wdays
              end
            end
          end
        end
      end
      
      
      
      # Expects a hash of values grouped by popularity
      # Yields the most popular values first, and then
      # increasingly less popular values
      def enumerate_by_popularity(values_by_popularity)
        popularities = values_by_popularity.keys.sort.reverse
        popularities.length.times do |i|
          at_popularities = popularities.take(i + 1)
          yield values_by_popularity.values_at(*at_popularities).flatten(1)
        end
      end
      
      
      
      def pick_best_guess(guesses, dates)
        scored_guesses = guesses \
          .map { |guess| [guess, score_guess(guess, dates)] } \
          .sort_by { |(guess, score)| -score.to_f }
        
        if @verbose
          puts "\nGUESSES FOR #{dates}:"
          scored_guesses.each do |(guess, score)|
            puts "  (%.3f p/%.3f b/%.3f c/%.3f) #{guess.humanize}" % [
              score.to_f,
              score.prediction_rate,
              score.brick_penalty,
              score.complexity_penalty]
          end
          puts ""
        end
        
        best_guess = scored_guesses.reject { |(guess, score)| score.to_f < 0.333 }.first
        best_guess || Schedule.new(kind: :never)
      end
      
      def score_guess(guess, input_dates)
        predicted_dates = guess.occurrences_between(guess.start_date, guess.end_date)
        
        # prediction_rate is the percent of input dates predicted
        predictions = (predicted_dates & input_dates).length
        prediction_rate = Float(predictions) / Float(input_dates.length)
        
        # bricks are dates predicted by this guess but not in the input
        bricks = (predicted_dates - input_dates).length
        
        # brick_rate is the percent of bricks to predictions
        # A brick_rate >= 1 means that this guess bricks more than it predicts
        brick_rate = Float(bricks) / Float(input_dates.length)
        
        # complexity measures how many rules are necesary
        # to describe the pattern
        complexity = complexity_of(guess)
        
        # complexity_rate is the number of rules per inputs
        complexity_rate = Float(complexity) / Float(input_dates.length)
        
        Score.new(prediction_rate, brick_rate, complexity_rate)
      end
      
      def complexity_of(schedule)
        return schedule.weekly_pattern.length if schedule.weekly?
        return schedule.monthly_pattern.length if schedule.monthly?
        1
      end
      
      
      
      def extract_array_of_dates!(dates)
        raise_invalid_dates_error! unless dates.respond_to?(:each)
        dates.map { |date| assert_date!(date) }.sort
      end
      
      def assert_date!(date)
        return date if date.is_a?(Date)
        date.to_date rescue raise_invalid_dates_error!
      end
      
      def raise_invalid_dates_error!
        raise ArgumentError.new("Inferrable.infer expects to receive a collection of dates")
      end
      
      
      
      class Score < Struct.new(:prediction_rate, :brick_rate, :complexity_rate)
        
        # as brick rate rises, our confidence in this guess drops
        def brick_penalty
          brick_penalty = brick_rate * 0.33
          brick_penalty = 1 if brick_penalty > 1
          brick_penalty
        end
        
        # as the complexity rises, our confidence in this guess drops
        # this hash table is a stand-in for a proper formala
        #
        # A complexity of 1 means that 1 rule is required per input
        # date. This means we haven't really discovered a pattern.
        def complexity_penalty
          complexity_rate
        end
        
        # our confidence is weakened by bricks and complexity
        def confidence
          confidence = 1.0
          confidence *= (1 - brick_penalty)
          confidence *= (1 - complexity_penalty)
          confidence
        end
        
        # a number between 0 and 1
        def to_f
          prediction_rate * confidence
        end
        
      end
      
      
    end
  end
end
