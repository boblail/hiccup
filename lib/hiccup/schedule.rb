require "hiccup"
require "active_model/validations"


module Hiccup
  class Schedule
    extend Hiccup
    include ActiveModel::Validations
    
    
    hiccup :enumerable,
           :validatable,
           :humanizable,
           :serializable => [:ical]
    
    
    def initialize(options={})
      @kind             =(options[:kind] || :never).to_sym
      @start_date       = options[:start_date] || Date.today
      @ends             = options.key?(:ends) ? options[:ends] : false
      @end_date         = options[:end_date]
      @skip             = options[:skip] || options[:interval] || 1
      @weekly_pattern   = options[:weekly_pattern] || []
      @monthly_pattern  = options[:monthly_pattern] || []
    end
    
    
    attr_accessor :kind, :start_date, :ends, :end_date, :skip, :weekly_pattern, :monthly_pattern
    
    
    def to_hash
      {
        :kind => kind,
        :start_date => start_date,
        :ends => ends,
        :end_date => end_date,
        :weekly_pattern => weekly_pattern,
        :monthly_pattern => monthly_pattern
      }
    end
    
    
  end
end