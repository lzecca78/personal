#!/usr/bin/env ruby
require 'spec_helper'

describe Util do

    before :each do
        @util = Util.new
        @from = Time.new(2002, 10, 31, 2, 2, 2, "+02:00")
    end

    describe "#new" do
        it "I can create Util object" do
            expect(@util).to be_an_instance_of Util
        end
    end

    describe "#last_24_hours" do
        it "return the date of 24 hours ago from a date passed as argument" do
            expected_date = Time.new(2002, 10, 30, 2, 2, 2, "+02:00")
            expect(@util.last_24_hours(@from)).to eql(expected_date)

        end
    end

    describe "#last_day_of_last_week" do
        it "return the date of the last day of the last week from a date passed as argument" do
            expected_date = Time.new(2002, 10, 24, 2, 2, 2, "+02:00")
            expect(@util.last_day_of_last_week(@from)).to eql(expected_date)
        end
    end

end
