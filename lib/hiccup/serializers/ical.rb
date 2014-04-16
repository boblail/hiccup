require "ri_cal"


module Hiccup
  module Serializers
    class Ical
      
      def initialize(klass)
        @klass = klass
      end
      
      
      
      def dump(obj)
        @component = RiCal::Component::Event.new
        @component.dtstart = obj.start_date.to_time if obj.start_date
        @obj = obj
        
        case obj.kind
        when :weekly;   add_weekly_rule
        when :monthly;  add_monthly_rule
        when :annually; add_yearly_rule
        end
        
        StringIO.new.tap {|io|
          @component.export_properties_to(io)
          @component.export_x_properties_to(io)
        }.string
      end
      
      
      
      def load(ics)
        return unless ics # Required for now, for ActiveRecord
        
        component_ics = "BEGIN:VEVENT\n#{ics}\nEND:VEVENT"
        component = RiCal.parse_string(component_ics).first
        
        @obj = @klass.new
        @obj.start_date = component.dtstart_property.try(:to_datetime)
        component.rrule_property.each do |rule|
          case rule.freq
          when "WEEKLY";    parse_weekly_rule(rule)
          when "MONTHLY";   parse_monthly_rule(rule)
          when "YEARLY";    parse_yearly_rule(rule)
          end
        end
        
        @obj
      end
      
      
      
    private
      
      
      
      def add_weekly_rule
        add_rule("WEEKLY", :byday => abbreviate_weekdays(@obj.weekly_pattern))
      end
      
      
      
      def add_monthly_rule
        byday = []
        bymonthday = []
        @obj.monthly_pattern.each do |occurrence|
          if occurrence.is_a?(Array)
            i, weekday = occurrence
            byday << "#{i}#{abbreviate_weekday(weekday)}"
          else
            bymonthday << occurrence
          end
        end
        
        add_rule("MONTHLY", :bymonthday => bymonthday) if bymonthday.any?
        add_rule("MONTHLY", :byday => byday) if byday.any?
      end
      
      
      
      def add_yearly_rule
        add_rule("YEARLY")
      end
      
      
      
      def add_rule(freq, options={})
        merge_default_options_for_new_rule!(freq, options)
        parent = options.delete(:parent)
        # puts "[add_rule] (#{parent.inspect}, #{options.inspect})"
        rrule = RiCal::PropertyValue::RecurrenceRule.new(parent, options)
        @component.rrule_property.push(rrule)
      end
      
      def merge_default_options_for_new_rule!(freq, options)
        options.merge!({
          :freq => freq,
          :interval => @obj.skip,
          :until => @obj.ends? && @obj.end_date && @obj.end_date.to_time
        })
      end
      
      
      
      
      
      def parse_weekly_rule(rule)
        @obj.kind = :weekly
        @obj.weekly_pattern = backmap_weekdays(rule.by_list[:byday])
        parse_rule(rule)
      end
      
      
      
      def parse_monthly_rule(rule)
        @obj.kind = :monthly
        parse_monthly_bymonthyday(rule.by_list[:bymonthday])
        parse_monthly_byday(rule.by_list[:byday])
        parse_rule(rule)
      end
      
      def parse_monthly_bymonthyday(bymonthday)
        (bymonthday || []).each do |bymonthday|
          @obj.monthly_pattern = @obj.monthly_pattern + [bymonthday.ordinal]
        end
      end
      
      def parse_monthly_byday(byday)
        (byday || []).each do |byday|
          @obj.monthly_pattern = @obj.monthly_pattern + [[byday.index, backmap_weekday(byday)]]
        end
      end
      
      
      
      def parse_yearly_rule(rule)
        @obj.kind = :annually
        parse_rule(rule)
      end
      
      
      
      def parse_rule(rule)
        @obj.skip = rule.interval
        if rule.until
          @obj.ends = true
          @obj.end_date = rule.until.to_datetime
        end
      end
      
      
      
      
      
      def abbreviate_weekdays(weekdays)
        weekdays.map(&method(:abbreviate_weekday)).compact
      end
      
      def abbreviate_weekday(weekday)
        WEEKDAY_MAP[weekday.to_s.downcase]
      end
      
      def backmap_weekdays(byday)
        byday ||= []
        byday.map(&method(:backmap_weekday)).compact
      end
      
      def backmap_weekday(byday)
        Date::DAYNAMES[byday.wday]
      end
      
      
      
      WEEKDAY_MAP = {
        "sunday" => "SU",
        "monday" => "MO",
        "tuesday" => "TU",
        "wednesday" => "WE",
        "thursday" => "TH",
        "friday" => "FR",
        "saturday" => "SA"
      }
      
      
      
    end
  end
end
