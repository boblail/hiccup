require "active_support/duration"


module Hiccup
  module CoreExt
    module DurationExtensions
      
      def from(*args)
        since(*args)
      end
      
      def after(*args)
        since(*args)
      end
      
      def before(*args)
        ago(*args)
      end
      
    end
  end
end


ActiveSupport::Duration.send(:include, Hiccup::CoreExt::DurationExtensions)
