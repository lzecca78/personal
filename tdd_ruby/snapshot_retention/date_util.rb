class Date_util
require 'active_support/core_ext'

    def last_24_hours(from)
        return 1.day.ago(from) 
    end

    def last_day_of_last_week(from)
        return 1.week.ago(from) 
    end

    def last_day_of_last_month(from)
      return 1.month.ago(from)
    end



end
