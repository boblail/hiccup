module Hiccup
  module CoreExt
    module EnumerableExtensions
      
      def to_histogram
        self.each_with_object(Hash.new { 0 }) do |item, histogram|
          pattern = block_given? ? yield(item) : item
          histogram[pattern] += 1
        end
      end
      
    end
  end
end

Enumerable.send(:include, Hiccup::CoreExt::EnumerableExtensions)
Array.send(:include, Hiccup::CoreExt::EnumerableExtensions)
