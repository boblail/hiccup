require "rubygems"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "hiccup/schedule"

require "minitest/reporters/turn_reporter"
MiniTest::Reporters.use! Minitest::Reporters::TurnReporter.new

require "active_support/core_ext"
require "shoulda/context"
require "minitest/autorun"
