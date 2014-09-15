#!/usr/bin/env ruby

require 'active_support/core_ext'

Class EndOfTheMonth
end

@array_ldotm = Array.new

def last_day_of_the_month (number_of_month_ago)
    number_of_months = 0..number_of_month_ago
    number_of_months.to_a.reverse.each do |month_offset|
        end_date = month_offset.months.ago.end_of_month
        @array_ldotm.push end_date
    end
    return @array_ldotm
end

sorted_array = last_day_of_the_month(44).sort

sorted_array.each do |ldotm|
  if (ldotm-Time.now).to_i < 1
    puts ldotm
  end
end
