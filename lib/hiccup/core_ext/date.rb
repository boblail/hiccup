module Hiccup
  module CoreExtensions
    module Date
      
      
      def get_months_since(earlier_date)
        ((self.year - earlier_date.year) * 12) + (self.month - earlier_date.month).to_int
      end
      
      def get_years_since(earlier_date)
        (self.year - earlier_date.year)
      end
      
      
      def get_months_until(later_date)
        later_date.months_since(self)
      end
      
      def get_years_until(later_date)
        later_date.years_since(self)
      end
      
      
    end
  end
end

Date.send     :include, Hiccup::CoreExtensions::Date
DateTime.send :include, Hiccup::CoreExtensions::Date
