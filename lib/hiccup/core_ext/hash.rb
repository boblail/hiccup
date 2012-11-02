module Hiccup
  module CoreExt
    module HashExtensions
      
      def group_by_value
        each_with_object({}) do |(key, value), new_hash|
          (new_hash[value]||=[]).push(key)
        end
      end
      alias :flip :group_by_value
      
    end
  end
end

Hash.send(:include, Hiccup::CoreExt::HashExtensions)
