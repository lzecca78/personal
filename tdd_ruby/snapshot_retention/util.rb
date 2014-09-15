class Util

    def last_24_hours(from)
        return from - calculate_seconds_to_be_subtracted(:day)
    end

    def last_day_of_last_week(from)
        return from - calculate_seconds_to_be_subtracted(:week)
    end

    def calculate_seconds_to_be_subtracted(ago)
        case 
            when ago == :day
            return (24 * 60 * 60)
            when ago == :week
            return (7 * 24 * 60 * 60)
        end
    end

end
