//
//  CLong+BYG.swift
//  BygApp
//
//  Created by Manish on 28/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

extension Double {
    func bygDateString() -> String {
        let date = NSDate(timeIntervalSince1970: self/1000.0)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MMM-YYYY"
        return formatter.stringFromDate(date)
    }
    
    func bygTimeString() -> String {
        let date = NSDate(timeIntervalSince1970: self/1000.0)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.stringFromDate(date)
    }
    
    func bygCurrencyString() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_IN")
        formatter.minimumFractionDigits = 0
        return formatter.stringFromNumber(self)!
    }
    
    func bygDoubleString() -> String {
        return self % 1 == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    func absoluteDateInDouble() -> Double {
        if let date = NSDate(timeIntervalSince1970: self).absoluteDate() {
            return date.timeIntervalSince1970
        }
        else {
            return 0
        }
        
    }
}

