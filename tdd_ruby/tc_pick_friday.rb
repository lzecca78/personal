#!/usr/bin/env ruby
require_relative "pick_day"
require "test/unit"

class TestTheDayIsMonday < Test::Unit::TestCase

  def test_day
    assert_equal('Monday', PickDay.new.dotw(2014, 9, 1) )

  end

end
