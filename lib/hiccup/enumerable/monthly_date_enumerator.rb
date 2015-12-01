require 'hiccup/enumerable/schedule_enumerator'

module Hiccup
  module Enumerable
    class MonthlyDateEnumerator < MonthlyEnumerator
    protected

      def occurrences_in_month(year, month)
        monthly_pattern.map(&method(:coerce_day_to_positive))
      end

    end
  end
end
