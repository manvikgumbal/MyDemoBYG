//
//  NSDate+Extension.swift
//  BygApp
//
//  Created by Prince Agrawal on 28/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

let timeIntervalOfADay:Double = 60*60*24
let calendar = NSCalendar.currentCalendar()

enum Day: String {
    case Monday = "monday"
    case Tuesday = "tuesday"
    case Wednesday = "wednesday"
    case Thursday = "thursday"
    case Friday = "friday"
    case Saturday = "saturday"
    case Sunday = "sunday"
}

struct BYGMonth {
    var name: String
    var days: [NSDate]
}

extension NSDate {
    func day() -> Int {
        return calendar.component(.Day, fromDate: self)
    }
    
    func weekDayString()-> Day {
        let weekDay = calendar.component(.Weekday, fromDate: self)
        
        var day: Day?
        
        switch weekDay {
        case 1:
            day = .Sunday
        case 2:
            day = .Monday
        case 3:
            day = .Tuesday
        case 4:
            day = .Wednesday
        case 5:
            day = .Thursday
        case 6:
            day = .Friday
        case 7:
            day = .Saturday
        default:
            day = .Monday
        }
        
        return day!
    }
    
    
    func weekDayChar() ->String {
        let weekDay = weekDayString().rawValue
        
        let firstChar = weekDay[weekDay.startIndex]
        
        return String(firstChar).uppercaseString
    }
    
    func monthString() -> String {
        let month = calendar.component(.Month, fromDate: self)
        return monthStringFromMonth(month)
    }
    
    func year() ->Int {
        return calendar.component(.Year, fromDate: self)
    }
    
    func absoluteDate() -> NSDate? { //Returns UTC Date with 00:00:00 timestamp
        let components = calendar.components(([.Day, .Month, .Year]), fromDate: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        components.timeZone = NSTimeZone(abbreviation: "UTC")
        
        return calendar.dateFromComponents(components)
    }
    
    func remainingDaysInMonth() ->Int {
        let daysInMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: self).length
        return daysInMonth - calendar.component(.Day, fromDate: self)
    }
    
    func nearDate(daysAfter:Int)-> NSDate? {
        let daysToAdd = NSDateComponents()
        daysToAdd.day = daysAfter
        return calendar.dateByAddingComponents(daysToAdd, toDate: self, options: .MatchStrictly)
    }
    
    func nearMonth(monthAfter: Int) -> String {
        let month = (calendar.component(.Month, fromDate: self) + monthAfter) % 12
        return monthStringFromMonth(month)
    }
    
    func daysInMonth(afterMonth: Int) ->Int {
        let calendar = NSCalendar.currentCalendar()
        let month = afterMonth + calendar.component(.Month, fromDate: self)
        
        let dateComponents = NSDateComponents()
        dateComponents.year = calendar.component(.Year, fromDate: self) + (month/12)
        dateComponents.month =  month%12
        
        let date = calendar.dateFromComponents(dateComponents)!
        return date.remainingDaysInMonth()
    }
    
    func dateFromLocalToUTCFormat() -> NSDate? {
        let timeZoneSeconds = NSTimeZone.localTimeZone().secondsFromGMT
        return self.dateByAddingTimeInterval(-Double(timeZoneSeconds))
    }
    
    //Class Functionsß
    class func workoutCalendar() ->[BYGMonth] {
        struct Holder {
            static var calendar = [BYGMonth]()
        }
        
        func initHolder() {
            
            var date = NSDate()
            for _ in 0...12 {
                var days = [NSDate]()
                for index in 0...date.remainingDaysInMonth() {
                    if let day = date.nearDate(index) {
                        days.append(day)
                    }
                }
                Holder.calendar.append(BYGMonth(name: date.monthString(), days: days))
                let lastMonthDay = days[days.count-1]
                date = lastMonthDay.nearDate(1)!
            }
            
        }
        
        if Holder.calendar.count == 0 {
            initHolder()
        }
        return Holder.calendar
    }
    
    class func daysBetweenDates(fromDate: NSDate?, toDate: NSDate = NSDate()) -> Int {
        var numberOfDays = 0
        if let fromDate = fromDate {
            let calendar: NSCalendar = NSCalendar.currentCalendar()
            let flags = NSCalendarUnit.Day
            let components = calendar.components(flags, fromDate: fromDate, toDate: toDate, options: [])
            numberOfDays = components.day
        }
        return numberOfDays
    }
    
    
    //MARK: Private Functions
    private func monthStringFromMonth(month: Int) ->String {
        
        var monthToReturn  = ""
        switch month {
        case 1:
            monthToReturn = "Jan"
        case 2:
            monthToReturn = "Feb"
        case 3:
            monthToReturn = "Mar"
        case 4:
            monthToReturn = "Apr"
        case 5:
            monthToReturn = "May"
        case 6:
            monthToReturn = "Jun"
        case 7:
            monthToReturn = "Jul"
        case 8:
            monthToReturn = "Aug"
        case 9:
            monthToReturn = "Sep"
        case 10:
            monthToReturn = "Oct"
        case 11:
            monthToReturn = "Nov"
        case 12:
            monthToReturn = "Dec"
        default:
            break
        }
        
        return monthToReturn
    }
    
    private func lastDayOfMonth() -> NSDate {
        let dayRange = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: self)
        let dayCount = dayRange.length
        let comp = calendar.components([.Year, .Month, .Day], fromDate: self)
        
        comp.day = dayCount
        
        return calendar.dateFromComponents(comp)!
    }
}
