//
//  APIManager.swift
//  BygApp
//
//  Created by Prince Agrawal on 08/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

class APIManager {
    
    class func updateAuthTokenDetails(response: JSONDictionary) {
        if let tokenDict = response[APIKeys.kToken] as? JSONDictionary {
            DataManager.jwtToken = tokenDict[APIKeys.kJWT] as? String
            DataManager.refreshToken = tokenDict[APIKeys.kRefreshToken] as? String
            DataManager.jwtExpiryDate = tokenDict[APIKeys.kExpiryTime] as? CLong
        }
    }

    class func errorForNetworkErrorReason(errorReason: NetworkErrorReason) -> NSError {
        var error: NSError!
        
        switch errorReason {
        case .InternetNotReachable:
            error = NSError(domain: "No Internet", code: -1, userInfo: [kMessage : "The Internet connection appears to be offline."])
        case .UnAuthorizedAccess:
            error = NSError(domain: "Authorization Failed", code: 0, userInfo: [kMessage : "Please Re-login to the app."])
        case let .FailureErrorCode(code, message):
            switch code {
            case 500:
                error = NSError(domain: "Server Error", code: code, userInfo: [kMessage : message])
            default:
                error = NSError(domain: "Oops!", code: code, userInfo: [kMessage : message])
            }
            
        case .Other:
            error = NSError(domain: "Oops!", code: 0, userInfo: [kMessage : "Something went wrong!"])
        }
        return error
    }
    
    //MARK: Validate jwt token closure
    static let validateToken = { (success: ((Bool) -> ())?) -> Void in
        
        guard let expiryDate:CLong = DataManager.jwtExpiryDate!/1000 where expiryDate > CLong(NSDate().timeIntervalSince1970 + TokenRefreshThresholdTimeInSeconds)
            else {
                OnboardingAPIService.RefreshToken().request(success:{ (response) in
                    if let responseDict = response as? JSONDictionary {
                        APIManager.updateAuthTokenDetails(responseDict)
                        success?(true)
                    }
                    else {
                        success?(false)
                    }
                    
                    }, failure: { (errorReason, error) in
                        UsersVM.sharedInstance.logoutTheUser()
                        success?(false)
                })
                return
        }
        success?(true)
    }
}