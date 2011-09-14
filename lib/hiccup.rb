require "hiccup/version"


# =======================================================
# Hiccup
# =======================================================
#
# This module contains mixins that can apply, serialize,
# validate, and humanize an object that models a recurrence
# pattern and which exposes the following properties:
#
# * kind - One of :never, :weekly, :monthly, :annually            # <== change to :none and :yearly
# * start_date - The date when the recurrence pattern
#   should start
# * ends - true or false indicating whether the recurrence
#   ever ends
# * end_date - The date when the recurrence pattern ends
# * skip - The number of instances to skip                        # <== change this to :interval
# * weekly_pattern - An array of recurrence rules for a
#   weekly recurrence
# * monthly_pattern - An array of recurrence rules for a
#   monthly recurrence
#
#   Examples:
#    
#    Every other Monday
#    :kind => :weekly, :weekly_pattern => ["Monday"]
#
#    Every year on June 21 (starting in 1999)
#    :kind => :yearly, :start_date => Date.new(1999, 6, 21)
#
#    The second and fourth Sundays of the month
#    :kind => :monthly, :monthly_pattern => [[2, "Sunday"], [4, "Sunday"]]
#
#
module Hiccup
  
  
  def hiccup(*modules)
    options = modules.extract_options!
    add_hiccup_modules(modules)
    add_hiccup_serialization_formats(options[:serializable])
  end
  
  
private
  
  
  def add_hiccup_modules(modules)
    (modules||[]).each {|name| add_hiccup_module(name)}
  end
  
  def add_hiccup_module(symbol)
    include_hiccup_module "hiccup/#{symbol}"
  end
  
  
  def add_hiccup_serialization_formats(formats)
    (formats||[]).each {|format| add_hiccup_serialization_format(format)}
  end
  
  def add_hiccup_serialization_format(format)
    include_hiccup_module "hiccup/serializable/#{format}"
  end
  
  
  def include_hiccup_module(module_path)
    require module_path
    include module_path.classify.constantize
  end
  
  
end


ActiveRecord::Base.extend(Hiccup) if defined?(ActiveRecord::Base)
