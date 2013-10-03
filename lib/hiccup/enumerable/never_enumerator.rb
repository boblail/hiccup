require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class NeverEnumerator < ScheduleEnumerator
      
      
      def next
        @cursor = @cursor ? nil : first_occurrence_on_or_after(seed_date)
      end
      
      def prev
        @cursor = @cursor ? nil : first_occurrence_on_or_before(seed_date)
      end
      
      
      def first_occurrence_on_or_after(date)
        start_date if date <= start_date
      end
      
      def first_occurrence_on_or_before(date)
        start_date unless date < start_date
      end
      
      
    end
  end
end
