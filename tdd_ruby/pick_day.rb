#!/usr/bin/env ruby
require 'date'
class PickDay
    #def last_friday(year, month)
    #  # Last day of month: Date.new interprets a negative number as a relative month/day from the end of year/month.
    #  d = Date.new(year, month, -1)
    #  d -= (d.wday - 5) % 7  # Subtract days after Friday.
    #end


    def dotw(year, month, day)
        date = Date.new(year, month, day)
        date.wday
        case  date.wday
        when 1
            return 'Monday'
        when 2
            return 'Tuesday'
        when 3
            return 'Wednesday'
        when 4
            return 'Thursday'
        when 5
            return 'Friday'
        when 6
            return 'Saturday'
        when 7
            return 'Sunday'
        end
    end
    #year = Integer(ARGV.shift)
    #(1..12).each {|month| puts last_friday(year, month)}
end

