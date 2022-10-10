//
//  DateFormatter.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/07.
//

import Foundation

fileprivate let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "ko_kr")
    f.timeZone = TimeZone(abbreviation: "KST")
    return f
}()

extension Date {
    var dateString: String {
        dateFormatter.dateFormat = "M월 d일"
        return dateFormatter.string(from: self)
    }
    
    var dateStringWithTimeAmPm: String {
        dateFormatter.dateFormat = "M월 d일 a hh:mm"
        return dateFormatter.string(from: self)
    }
    
    var yearString: String {
        dateFormatter.dateFormat = "yyyy년"
        return dateFormatter.string(from: self)
    }
    
    var monthString: String {
        dateFormatter.dateFormat = "M월"
        return dateFormatter.string(from: self)
    }
    
    var yearMonthString: String {
        dateFormatter.dateFormat = "yyyy년 M월"
        return dateFormatter.string(from: self)
    }
    
    var timeString: String {
        dateFormatter.dateFormat = "HH:00"
        return dateFormatter.string(from: self)
    }
    
    var timeStringWithAmPm: String {
        dateFormatter.dateFormat = "a hh:mm"
        dateFormatter.amSymbol = "오전"
        dateFormatter.pmSymbol = "오후"
        return dateFormatter.string(from: self)
    }
}
