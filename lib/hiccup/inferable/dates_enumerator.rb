module Hiccup
  module Inferable
    class DatesEnumerator

      def initialize(dates)
        @dates = dates
        @last_index = @dates.length - 1
        @index = -1
      end

      attr_reader :index

      def done?
        @index == @last_index
      end

      def next
        @index += 1
        raise OutOfRangeException if @index > @last_index
        @dates[@index]
      end

      def rewind_by(n)
        @index -= n
        @index = -1 if @index < -1
      end

    end
  end
end
