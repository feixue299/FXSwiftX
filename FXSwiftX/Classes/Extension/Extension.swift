//
//  Extension.swift
//  FXKit
//
//  Created by iMac on 2021/4/6.
//

import Foundation

public extension Date {
    
    /// 获取当前周的时间段
    /// - Returns: start: 开始时间，end：结束时间
    func getWeekTime() -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        let comp = calendar.dateComponents([.year, .month, .day, .weekday], from: self)
        guard let weekday = comp.weekday, let day = comp.day else { return nil }
        
        let start: Int
        let end: Int
        if weekday == 1 {
            start = -6
            end = 0
        } else {
            start = calendar.firstWeekday - weekday + 1
            end = 8 - weekday
        }
        var firstDayComp = calendar.dateComponents([.year, .month, .day], from: self)
        firstDayComp.day = day + start
        guard let firstDayOfWeek = calendar.date(from: firstDayComp) else { return nil }
        var lastDayComp = calendar.dateComponents([.year, .month, .day], from: self)
        lastDayComp.day = day + end
        guard let lastDayOfWeek = calendar.date(from: lastDayComp) else { return nil }
        return (firstDayOfWeek, lastDayOfWeek)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var dayOfMonth: Int? {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: self)
        let dayOfMonth: Int? = range?.upperBound
        return dayOfMonth.map({ $0 - 1 })
    }
}

public extension Data {
    var array: Array<Element> {
        return Array(self)
    }
}

public extension Int {
    var bcdValue: [UInt8] {
        let str = Array("\(self)")
        let snippetCount = (str.count / 2) + (str.count % 2 == 0 ? 0 : 1)
        let arr = (0..<snippetCount).reversed().map({ index -> UInt8 in
            let endIndex = Swift.min(index * 2, str.count - 1)
            let startIndex = Swift.max(endIndex - 1, 0)
            let string = String(str[startIndex...endIndex])
            let int = Int(string)!
            let uint8: UInt8 = UInt8(int / 10 * 16 + int % 10)
            return uint8
        })
        
        return arr.reversed()
    }
}

public extension Array where Element == UInt8 {
    var hexString: String {
        return self.compactMap { String(format: "%02x", $0).uppercased() }
        .joined(separator: "")
    }
}

public extension Optional {
    func `let`(_ closure: (Wrapped) -> Void) {
        switch self {
        case .some(let value):
            closure(value)
        case .none:
            break
        }
    }
}
