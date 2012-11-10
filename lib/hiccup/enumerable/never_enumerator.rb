require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class NeverEnumerator < ScheduleEnumerator
      
      
      def first_occurrence_on_or_after(date)
        date if date == start_date
      end
      
      def first_occurrence_on_or_before(date)
        date
      end
      
      
    end
  end
end
