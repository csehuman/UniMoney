//
//  DateManager.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/13.
//

import Foundation

class DateManager {
    static let shared = DateManager()
    private init() { }
    
    func getDate(year: Int, month: Int = 1, day: Int = 1) -> Date {
        let beginDateComponents = ["year": year, "month": month, "day": day, "hour": 0, "minute": 0, "second": 0]
        
        let beginDate = makeDate(from: beginDateComponents)
        
        return beginDate
    }
    
    func getTodayDate() -> (Int, Int, Int) {
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        return (components.year!, components.month!, components.day!)
    }
    
    func getPreviousDay(year: Int, month: Int, day: Int) -> (Int, Int, Int) {
        var newYear = year
        var newMonth = month
        var newDay = day
        
        if day == 1 {
            if month == 1 {
                newMonth = 12
                newYear = year - 1
            } else {
                newMonth = month - 1
            }
            newDay = getLastDayOfMonthComponents(forMonth: month).day!
        } else {
            newDay = day - 1
        }
        
        return (newYear, newMonth, newDay)
    }
    
    func getPreviousMonth(year: Int, month: Int) -> (Int, Int) {
        var newYear = year
        var newMonth = month
        
        if month == 1 {
            newMonth = 12
            newYear = year - 1
        } else {
            newMonth = month - 1
        }
        
        return (newYear, newMonth)
    }
    
    func getPreviousYear(year: Int) -> Int {
        var newYear = year
        newYear = year - 1
        
        return newYear
    }
    
    func getNextDay(year: Int, month: Int, day: Int) -> (Int, Int, Int) {
        var newYear = year
        var newMonth = month
        var newDay = day
        
        if day == getLastDayOfMonthComponents(forMonth: month).day! {
            if month == 12 {
                newMonth = 1
                newYear = year + 1
            } else {
                newMonth = month + 1
            }
            newDay = 1
        } else {
            newDay = day + 1
        }
        
        return (newYear, newMonth, newDay)
    }
    
    func getNextMonth(year: Int, month: Int) -> (Int, Int) {
        var newYear = year
        var newMonth = month

        if month == 12 {
            newMonth = 1
            newYear = year + 1
        } else {
            newMonth = month + 1
        }
        
        return (newYear, newMonth)
    }
    
    func getNextYear(year: Int) -> Int {
        var newYear = year
        newYear = year + 1
        
        return newYear
    }
    
    func getDayRange(year: Int, month: Int, day: Int) -> (Date, Date) {
        let beginDateComponents = ["year": year, "month": month, "day": day, "hour": 0, "minute": 0, "second": 0]
        let endDateComponents = ["year": year, "month": month, "day": day, "hour": 23, "minute": 59, "second": 59]
        
        let beginDate = makeDate(from: beginDateComponents)
        let endDate = makeDate(from: endDateComponents)
        
        return (beginDate, endDate)
    }
    
    func getMonthRange(year: Int, month: Int) -> (Date, Date) {
        let beginDateComponents = ["year": year, "month": month, "day": 1, "hour": 0, "minute": 0, "second": 0]
        
        let beginDate = makeDate(from: beginDateComponents)
        let lastDayComponents = getLastDayOfMonthComponents(forMonth: month)
        
        let endDateComponents = ["year": year, "month": month, "day": lastDayComponents.day!, "hour": 23, "minute": 59, "second": 59]
        
        let endDate = makeDate(from: endDateComponents)
        
        return (beginDate, endDate)
    }
    
    func getYearRange(year: Int) -> (Date, Date) {
        let beginDateComponents = ["year": year, "month": 1, "day": 1, "hour": 0, "minute": 0, "second": 0]
        let endDateComponents = ["year": year, "month": 12, "day": 31, "hour": 23, "minute": 59, "second": 59]
        
        let beginDate = makeDate(from: beginDateComponents)
        let endDate = makeDate(from: endDateComponents)
        
        return (beginDate, endDate)
    }
    
    private func getLastDayOfMonthComponents(forMonth month: Int) -> DateComponents {
        let dateComponents = ["year": 2001, "month": month, "day": 1, "hour": 0, "minute": 0, "second": 0]
        let date = makeDate(from: dateComponents)
        
        let components = DateComponents(month: 1, second: -1)
        let endMonth = Calendar(identifier: .gregorian).date(byAdding: components, to: date)!
        let calendarDate = Calendar.current.dateComponents([.day], from: endMonth)
        
        return calendarDate
    }
    
    private func makeDate(from components: [String: Int]) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = components["year"]
        dateComponents.month = components["month"]
        dateComponents.day = components["day"]
        dateComponents.hour = components["hour"]
        dateComponents.minute = components["minute"]
        dateComponents.second = components["second"]
        
        let resultDate = Calendar(identifier: .gregorian).date(from: dateComponents)
        
        return resultDate!
    }
}
