//
//  ApiService+Order.swift
//  BygApp
//
//  Created by Manish on 20/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

enum OrderAPIService: APIService {
    
    case GenerateOrder()
    
    case PlaceOrder(walletAmount: Double, couponCode: String?)
    
    case GetBookings()
    
    case GetMeCards()

    var path: String {
        var path = ""
        switch self {
            
        case .GenerateOrder:
            path = BASE_API_URL.stringByAppendingString("/v1.1/order/generate")
            
        case .PlaceOrder:
            path = BASE_API_URL.stringByAppendingString("/v1.1/order/place")
        
        case .GetBookings:
            path = BASE_API_URL.stringByAppendingString("/v1.1/order/bookings")
            
        case .GetMeCards:
            path = BASE_API_URL.stringByAppendingString("/v1.1/orders")
            
        }
        return path
    }
    
    var resource: Resource {
        var resource: Resource!
        switch self {
            
        case .GenerateOrder():
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case let .PlaceOrder(WalletAmount, CouponCode):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kWalletAmount] = WalletAmount
            parametersDict[APIKeys.kCoupon] = CouponCode
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case .GetBookings():
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case .GetMeCards():
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
        }
        return resource
    }
}

extension APIManager {
    
    class func getBookings(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                OrderAPIService.GetBookings().request(success:{ (response) in
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
    
    class func getMeCards(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                OrderAPIService.GetMeCards().request(success:{ (response) in
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

    class func placeOrder(walletAmount: Double, couponCode: String?, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                OrderAPIService.PlaceOrder(walletAmount: walletAmount, couponCode: couponCode).request(success: { (response) in
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

