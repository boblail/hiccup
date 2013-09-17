require 'active_support/concern'
require 'active_support/core_ext/date/conversions'
require 'hiccup/core_ext/enumerable'
require 'hiccup/core_ext/hash'
require "hiccup/core_ext/date"
require 'hiccup/inferable/dates_enumerator'
require 'hiccup/inferable/guesser'
require 'hiccup/inferable/score'


module Hiccup
  module Inferable
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      def infer(dates, options={})
        allow_null_schedules = options.fetch(:allow_null_schedules, false)
        verbosity = options.fetch(:verbosity, (options[:verbose] ? 1 : 0)) # 0, 1, or 2
        
        dates = extract_array_of_dates!(dates)
        enumerator = DatesEnumerator.new(dates)
        guesser = Guesser.new(self, {verbose: verbosity >= 2})
        schedules = []
        
        confidences = []
        high_confidence_threshold = 0.6
        min_confidence_threshold  = 0.35
        
        last_confident_schedule = nil
        iterations_since_last_confident_schedule = 0
        
        until enumerator.done?
          date = enumerator.next
          guesser << date
          confidence = guesser.confidence.to_f
          confidences << confidence
          predicted = guesser.predicted?(date)
          
          # if the last two confidences are both below a certain
          # threshhold and both declining, back up to where we
          # started to go wrong and start a new schedule.
          
          confident = !(confidences.length >= 3 && (
                        (confidences[-1] < high_confidence_threshold &&
                         confidences[-2] < high_confidence_threshold &&
                         confidences[-1] < confidences[-2] &&
                         confidences[-2] < confidences[-3]) ||
                        (confidences[-1] < min_confidence_threshold &&
                         confidences[-2] < min_confidence_threshold)))
          
          if predicted && confidence >= min_confidence_threshold
            iterations_since_last_confident_schedule = 0
            last_confident_schedule = guesser.schedule
          else
            iterations_since_last_confident_schedule += 1
          end
          
          rewind_by = iterations_since_last_confident_schedule == guesser.count ? iterations_since_last_confident_schedule - 1 : iterations_since_last_confident_schedule
          
          
          
          if verbosity >= 1
            output = "  #{enumerator.index.to_s.rjust(3)} #{date}"
            output << " #{"[#{guesser.count}]".rjust(5)}  =>  "
            output << "~#{(guesser.confidence.to_f * 100).to_i.to_s.rjust(2, "0")} @ "
            output << guesser.schedule.humanize.ljust(130)
            output << "  :( move back #{rewind_by}" unless confident
            puts output
          end
          
          
          
          unless confident
            
            if last_confident_schedule
              schedules << last_confident_schedule
            elsif allow_null_schedules
              guesser.dates.take(guesser.count - rewind_by).each do |date|
                schedules << self.new(:kind => :never, :start_date => date)
              end
            end
            
            enumerator.rewind_by(rewind_by)
            guesser.restart!
            confidences = []
            iterations_since_last_confident_schedule = 0
            last_confident_schedule = nil
          end
        end
        
        if last_confident_schedule
          schedules << last_confident_schedule
        elsif allow_null_schedules
          guesser.dates.each do |date|
            schedules << self.new(:kind => :never, :start_date => date)
          end
        end
        
        schedules
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
        raise ArgumentError.new("Inferable.infer expects to receive a collection of dates")
      end
      
      
      
    end
  end
end
