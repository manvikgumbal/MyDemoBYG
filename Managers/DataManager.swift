//
//  DataManager.swift
//  BygApp
//
//  Created by Prince Agrawal on 20/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

class DataManager {
    static var deviceToken:String? {
        set {
           NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kDeviceToken)
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        get {
           return NSUserDefaults.standardUserDefaults().stringForKey(kDeviceToken)
        }
    }
    
    static var jwtToken:String? {
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kJWTToken)
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(kJWTToken)
        }
    }
    
    static var refreshToken:String? {
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kRefreshToken)
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(kRefreshToken)
        }
    }
    
    static var jwtExpiryDate: CLong? {
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kJWTExpiryDate)
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(kJWTExpiryDate) as? CLong
        }
    }

    static var selectedLocation: [String:AnyObject]? {
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kselectedLocation)
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName(kLocationChangeNotification, object: nil)
        }
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(kselectedLocation) as? [String:AnyObject]
        }
    }
    
    static var isFirstTimeLogin: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kFirstTimeLogin)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kFirstTimeLogin)
        }
    }
    
    static var totalLogins: Int? {
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kTotalLogin)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(kTotalLogin)
        }
    }
    
    static var lastDayPopUp: NSDate? {
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: kLastDayOfPop)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().valueForKey(kLastDayOfPop) as? NSDate
        }
    }
    
    static var isReferDone: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kReferDone)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kReferDone)
        }
    }
    
    static var isRateDone: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kRateDone)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kRateDone)
        }
    }
    
    static var isProfileCompleted: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kProfileCompleted)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kProfileCompleted)
        }
    }
    
    static var isRatingDone: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kRatingDone)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kRatingDone)
        }
    }
    
    static var isBYGMoneyAdded: Bool {
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kIsBYGMoneyAdded)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(kIsBYGMoneyAdded)
        }
    }

}