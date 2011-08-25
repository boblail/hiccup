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
      @kind       = options[:kind] || :never
      @start_date = options[:start_date] || Date.today
      @ends       = options.key?(:ends) ? options[:ends] : false
      @end_date   = options[:end_date]
      @skip       = options[:skip] || options[:interval] || 1
      @pattern    = options[:pattern] || []
    end
    
    
    attr_accessor :kind, :start_date, :ends, :end_date, :skip, :pattern
    
    
    def to_hash
      {
        :kind => kind,
        :start_date => start_date,
        :ends => ends,
        :end_date => end_date,
        :pattern => pattern
      }
    end
    
    
  end
end