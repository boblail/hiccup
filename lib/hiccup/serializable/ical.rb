require "hiccup/serializers/ical"
require "active_support/concern"


module Hiccup
  module Serializable
    module Ical
      extend ActiveSupport::Concern
      
      
      def to_ical
        ical_serializer.dump(self)
      end
      
      
      module ClassMethods
        
        def from_ical(ics)
          ical_serializer.load(ics)
        end
        
        def ical_serializer
          @ical_serializer ||= Serializers::Ical.new(self)
        end
        
      end
      
      
    private
      
      
      def ical_serializer
        self.class.ical_serializer
      end
      
      
    end
  end
end
