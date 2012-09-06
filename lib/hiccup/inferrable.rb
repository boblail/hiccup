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
        
        guesses << self.new.tap do |schedule|
          schedule.kind = :annually
          schedule.start_date = start_date
          schedule.end_date = end_date
        end
        
        guesses << self.new.tap do |schedule|
          schedule.kind = :monthly
          schedule.start_date = start_date
          schedule.end_date = end_date
          schedule.monthly_pattern = [4]
        end
        
        guesses << self.new.tap do |schedule|
          schedule.kind = :weekly
          schedule.start_date = start_date
          schedule.end_date = end_date
          schedule.weekly_pattern = [Date::DAYNAMES[start_date.wday]]
        end
        
        guesses
      end
      
      
      
      def pick_best_guess(guesses, dates)
        top_score = 0
        best_guess = nil
        guesses.each do |guess|
          score = guess_score(guess, dates)
          if score > top_score
            top_score = score
            best_guess = guess
          end
        end
        best_guess
      end
      
      def guess_score(guess, dates)
        guess_dates = guess.occurrences_between(guess.start_date, guess.end_date)
        failure_count = (dates - guess_dates).length
        brick_count = (guess_dates - dates).length
        1000 - (failure_count + brick_count)
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
