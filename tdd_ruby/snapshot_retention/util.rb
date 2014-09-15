class Util

    def last_24_hours(from)
        return from - (24 * 60 * 60)
    end

    def last_day_of_last_week(from)
        return from - (7 * 24 * 60 * 60)
    end

end
