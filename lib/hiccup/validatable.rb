require "hiccup/convenience"
require "active_support/concern"


module Hiccup
  module Validatable
    include Convenience
    extend ActiveSupport::Concern


    # !todo: use ActiveModel:Validation rather than a custom method
    included do
      validates :skip, numericality: {greater_than: 0}
      validate                    :validate_recurrence
    end


  private


    # !todo: use i18n to let clients of this library supply their own wording
    def validate_recurrence
      case kind
      when :never;
      when :weekly;     validate_weekly_recurrence
      when :monthly;    validate_monthly_recurrence
      when :annually;
      else;             invalid_kind!
      end

      errors.add :start_date, "is a #{start_date.class} not a Date" unless start_date.is_a?(Date)
      if ends?
        if end_date.is_a?(Date)
          errors.add :end_date, "cannot be before start" if start_date.is_a?(Date) && end_date < start_date
        else
          errors.add :end_date, "is a #{end_date.class} not a Date"
        end
      end
    end


    def validate_weekly_recurrence
      if !weekly_pattern.is_a?(Array)
        errors.add(:weekly_pattern, "is a #{weekly_pattern.class}. It should be an array")
      elsif weekly_pattern.empty?
        errors.add(:weekly_pattern, "is empty. It should contain a list of weekdays")
      elsif (invalid_names = weekly_pattern - Date::DAYNAMES).any?
        errors.add(:weekly_pattern, "should contain only weekdays. (#{invalid_names.to_sentence} are invalid)")
      end
    end


    def validate_monthly_recurrence
      if !monthly_pattern.is_a?(Array)
        errors.add(:monthly_pattern, "is a #{monthly_pattern.class}. It should be an array")
      elsif monthly_pattern.empty?
        errors.add(:monthly_pattern, "is empty. It should contain a list of monthly occurrences")
      elsif monthly_pattern.select(&method(:invalid_occurrence?)).any?
        errors.add(:monthly_pattern, "contains invalid monthly occurrences")
      end
    end


    def invalid_occurrence?(occurrence)
      !valid_occurrence?(occurrence)
    end

    def valid_occurrence?(occurrence)
      if occurrence.is_a?(Array)
        i, wd = occurrence
        Date::DAYNAMES.member?(wd) && i.is_a?(Integer) && ((i == -1) || (1..6).include?(i))
      else
        i = occurrence
        i.is_a?(Integer) && ([-1] + (1..31).to_a).include?(i)
      end
    end


    def invalid_kind!
      errors.add(:kind, "#{kind.inspect} is not recognized. It must be one of #{Kinds.collect{|kind| ":#{kind}"}.to_sentence(:two_words_connector => " or ", :last_word_connector => ", or ")}.")
    end


    # def valid_occurrence?(occurrence)
    #   if occurrence.is_a?(Array)
    #     ordinal, kind = occurrence
    #
    #     errors.add(:kind, "is not a valid monthly occurrence kind") unless Date::DAYNAMES.member?(kind)
    #     if ordinal.is_a?(Integer)
    #       errors.add(:ordinal, "is not a valid integer") unless (ordinal==-1) or (1..6).include?(ordinal)
    #     else
    #       errors.add(:ordinal, "is not an integer")
    #     end
    #   else
    #     ordinal = occurrence
    #
    #     if ordinal.is_a?(Integer)
    #       errors.add(:ordinal, "is not an integer between 1 and 31") unless (1..31).include?(ordinal)
    #     else
    #       errors.add(:ordinal, "is not an integer")
    #     end
    #   end
    # end


  end
end
