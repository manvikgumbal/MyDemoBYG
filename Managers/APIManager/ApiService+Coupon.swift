//
//  ApiService+Coupon.swift
//  BygApp
//
//  Created by Manish on 20/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

enum CouponAPIService: APIService {
    
    case GetCoupons()
    
    case ValidateCoupon(code: String, amount: String, userId: String, gymName: String, city: String, bookingType: String)
    
    var path: String {
        var path = ""
        switch self {
        case .GetCoupons:
            path = BASE_API_URL.stringByAppendingString("/v1/coupons/app")
            
        case .ValidateCoupon:
            path = BASE_API_URL.stringByAppendingString("/v1/coupon/validate")
            
        }
        return path
    }
    
    var resource: Resource {
        var resource: Resource!
        switch self {
            
        case .GetCoupons():
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case let .ValidateCoupon(code, amount, userId, gymName, city, bookingType):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kCode] = code
            parametersDict[APIKeys.kAmount] = amount
            parametersDict[APIKeys.kUserID] = userId
            parametersDict[APIKeys.kName] = gymName
            parametersDict[APIKeys.kCity] = city
            parametersDict[APIKeys.kBookingType] = bookingType
            resource = Resource(method: .POST, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])

            
            
        }
        return resource
    }
}

