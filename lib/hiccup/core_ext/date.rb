module Hiccup
  module CoreExtensions
    module Date



      def get_nth_wday_of_month
        (day - 1) / 7 + 1
      end

      def get_nth_wday_string
        "#{get_nth_wday_of_month} #{::Date::DAYNAMES[wday]}"
      end



    end
  end
end

Date.send     :include, Hiccup::CoreExtensions::Date
DateTime.send :include, Hiccup::CoreExtensions::Date
