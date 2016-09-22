//
//  ApiService+Cart.swift
//  BygApp
//
//  Created by Manish on 20/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

enum CartAPIService: APIService {
    
    case AddToCart(serviceId: String, startDate: Double, scheduleId: String?)
    
    case DeleteFromCart(serviceId: String, scheduleID: String?, startDate: Double)
    
    case GetCartItems()
    
    case GetAvailableCoupons()
    
    case ValidateCoupons(code: String, amount: Double, userId: String, gymName: String, city: String, bookingType: String)
    
    var path: String {
        var path = ""
        switch self {
        case .AddToCart:
            path = BASE_API_URL.stringByAppendingString("/v1.1/cart")
            
        case .DeleteFromCart:
            path = BASE_API_URL.stringByAppendingString("/v1.1/cart")
            
        case .GetCartItems:
            path = BASE_API_URL.stringByAppendingString("/v1.1/cart")
            
        case .GetAvailableCoupons:
            path = BASE_API_URL.stringByAppendingString("/v1/coupons/app")
            
        case .ValidateCoupons:
            path = BASE_API_URL.stringByAppendingString("/v1/coupon/validate")
            
        }
        return path
    }
    
    var resource: Resource {
        var resource: Resource!
        switch self {
            
        case let .AddToCart(serviceId, startDate, scheduleId):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kServiceID] = serviceId
            parametersDict[APIKeys.kStartDate] = startDate
            parametersDict[APIKeys.kScheduleID] = scheduleId
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case let .DeleteFromCart(serviceId, scheduleID, startDate):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kServiceID] = serviceId
            parametersDict[APIKeys.kScheduleID] = scheduleID
            parametersDict[APIKeys.kStartDate] = startDate
            resource = Resource(method: .DELETE, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)","User-Agent":"iOS"])
                        
        case .GetCartItems:
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case .GetAvailableCoupons:
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case let .ValidateCoupons(code, amount, userId, gymName, city, bookingType):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kCode] = code
            parametersDict[APIKeys.kAmount] = amount
            parametersDict[APIKeys.kUserID] = userId
            parametersDict[APIKeys.kGymName] = gymName
            parametersDict[APIKeys.kCity] = city
            parametersDict[APIKeys.kBookingType] = bookingType
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
        }
        return resource
    }
}

extension APIManager {
    
    class func validateCoupon(code: String, amount: Double, userId: String, gymName: String, city: String, bookingType: String, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                CartAPIService.ValidateCoupons(code: code, amount: amount, userId: userId, gymName: gymName, city: city, bookingType: bookingType).request(success: { (response) in
                    if let responseDict = response as? JSONDictionary {
                        successCallback(responseDict)
                    }
                    else {
                        successCallback([:])
                    }
                    }, failure: failureCallback)
            }
            else {
                failureCallback(NetworkErrorReason.UnAuthorizedAccess, nil)
            }
        })
    }
    
    class func addItemToCart(serviceId: String, startDate: Double, scheduleId: String? = nil, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                CartAPIService.AddToCart(serviceId: serviceId, startDate: startDate, scheduleId: scheduleId).request(success: { (response) in
                    if let responseDict = response as? JSONDictionary {
                        successCallback(responseDict)
                    }
                    else {
                        successCallback([:])
                    }
                    }, failure: failureCallback)
            }
            else {
                failureCallback(NetworkErrorReason.UnAuthorizedAccess, nil)
            }
        })
    }
    
    class func deleteItemFromCart(serviceId: String, scheduleID: String?, startDate: Double, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                CartAPIService.DeleteFromCart(serviceId: serviceId, scheduleID: scheduleID, startDate: startDate).request(success: { (response) in
                    if let responseDict = response as? JSONDictionary {
                        successCallback(responseDict)
                    }
                    else {
                        successCallback([:])
                    }
                    }, failure: failureCallback)
            }
            else {
                failureCallback(NetworkErrorReason.UnAuthorizedAccess, nil)
            }
        })
    }
    
    class func generateOrder(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                OrderAPIService.GenerateOrder().request(success: { (response) in
                    if let responseDict = response as? JSONDictionary {
                        successCallback(responseDict)
                    }
                    else {
                        successCallback([:])
                    }
                    }, failure: failureCallback)
            }
            else {
                failureCallback(NetworkErrorReason.UnAuthorizedAccess, nil)
            }
        })
    }
    
    
    class func getCoupons(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                CouponAPIService.GetCoupons().request(success: { (response) in
                    if let responseDict = response as? JSONDictionary {
                        successCallback(responseDict)
                    }
                    else {
                        successCallback([:])
                    }
                    }, failure: failureCallback)
            }
            else {
                failureCallback(NetworkErrorReason.UnAuthorizedAccess, nil)
            }
        })
    }
    
    class func getCartItems(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                CartAPIService.GetCartItems().request(success: { (response) in
                    if let responseDict = response as? JSONDictionary {
                        successCallback(responseDict)
                    }
                    else {
                        successCallback([:])
                    }
                    }, failure: failureCallback)
            }
            else {
                failureCallback(NetworkErrorReason.UnAuthorizedAccess, nil)
            }
        })
    }
    
    class func fetchAvailableCoupons(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                CartAPIService.GetAvailableCoupons().request(success: { (response) in
                    if let responseDict = response as? JSONDictionary {
                        successCallback(responseDict)
                    }
                    else {
                        successCallback([:])
                    }
                    }, failure: failureCallback)
            }
            else {
                failureCallback(NetworkErrorReason.UnAuthorizedAccess, nil)
            }
        })
    }
    
}

