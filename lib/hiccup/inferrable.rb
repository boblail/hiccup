require 'active_support/concern'
require 'active_support/core_ext/date/conversions'


module Hiccup
  module Inferrable
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      
      
      def infer(dates)
        dates = extract_array_of_dates!(dates)
        guesses = generate_guesses(dates)
        pick_best_guess(guesses, dates)
      end
      
      
      
      def generate_guesses(dates)
        start_date = dates.min
        end_date = dates.max
        guesses = []
        
        
        (1...5).each do |skip|
          guesses << self.new.tap do |schedule|
            schedule.kind = :annually
            schedule.start_date = start_date
            schedule.end_date = end_date
            schedule.skip = skip
          end
        end
        
        (1...5).each do |skip|
          guesses << self.new.tap do |schedule|
            schedule.kind = :monthly
            schedule.start_date = start_date
            schedule.end_date = end_date
            schedule.skip = skip
            schedule.monthly_pattern = [start_date.day]
          end
          
          guesses << self.new.tap do |schedule|
            schedule.kind = :monthly
            schedule.start_date = start_date
            schedule.end_date = end_date
            schedule.skip = skip
            schedule.monthly_pattern = dates.map { |date|
              [date.get_nth_wday_of_month, Date::DAYNAMES[date.wday]]
            }.uniq
          end
        end
        
        (1...5).each do |skip|
          guesses << self.new.tap do |schedule|
            schedule.kind = :weekly
            schedule.start_date = start_date
            schedule.end_date = end_date
            schedule.skip = skip
            # schedule.weekly_pattern = histogram_of_wdays.keys.map { |wday| Date::DAYNAMES[wday] }
            schedule.weekly_pattern = dates.map(&:wday).uniq.map { |wday| Date::DAYNAMES[wday] }
          end
        end
        
        guesses
      end
      
      
      
      def pick_best_guess(guesses, dates)
        top_score = 0
        best_guess = nil
        guesses.each do |guess|
          score = score_guess(guess, dates)
          if score > top_score
            top_score = score
            best_guess = guess
          end
        end
        best_guess
      end
      
      def score_guess(guess, input_dates)
        predicted_dates = guess.occurrences_between(guess.start_date, guess.end_date)
        
        # Failures are input dates that were not predicted by this guess
        failure_count = (input_dates - predicted_dates).length
        
        # Bricks are dates that _were_ predicted by this guess but are not in the input
        brick_count = (predicted_dates - input_dates).length
        
        pattern_complexity = 1
        pattern_complexity = guess.weekly_pattern.length if guess.weekly?
        pattern_complexity = guess.monthly_pattern.length if guess.monthly?
        
        # Failures are more serious than bricks
        1000 - ((failure_count * 2.0) + brick_count + (pattern_complexity * 0.75))
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
      
      
      
    end
  end
end
