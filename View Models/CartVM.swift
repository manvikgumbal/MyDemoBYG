//
//  CartVM.swift
//  BygApp
//
//  Created by Manish on 23/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import UIKit


@objc protocol CartVMDelegate {
    optional func didFetchCoupons(success: Bool, error: NSError?)
    optional func didValidateCoupon(success: Bool, error: NSError?)
    optional func didValidateToken(success: Bool, error: NSError?)
    
    optional func didUpdateItemsToCart(success: Bool, error: NSError?)
    optional func didFetchCartDetails(success: Bool, error: NSError?)
    optional func didGenerateOrder(success: Bool, error: NSError?)
    optional func didPlaceOrder(success: Bool, error: NSError?, orderStatus: String? , orderID: String?)
    
    optional func didCompletePayment(success: Bool, error: NSError?)
}

public class CartVM {
    
    public static let sharedInstance = CartVM()
    private init() {}
    
    weak var delegate: CartVMDelegate?
    var cartItems: [String:[CartItem]]? {
        didSet {
            if cartItems?.count > 0 {
                var count = 0
                for value in Array(cartItems!.values) ?? [] {
                    count = count + value.count
                }
                NSNotificationCenter.defaultCenter().postNotificationName(kCartUpdateNotification, object: nil, userInfo: [kCartQuantity: count])
            }
            else {
                NSNotificationCenter.defaultCenter().postNotificationName(kCartUpdateNotification, object: nil, userInfo: nil)
            }
        }
    }
    
    var coupons = [Coupon]()
    var totalAmount: Double?
    var couponCode: String?
    var discount: Double?
    var orderId: String?
    
    
    func getCartItems() {
        APIManager.getCartItems({ (responseDict) in
            if let items = responseDict?[APIKeys.kCart]?[APIKeys.kItems] as? JSONArray {
                self.parseCartFromResponse(items)
                self.delegate?.didFetchCartDetails?(true, error: nil)
            }
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.delegate?.didFetchCartDetails?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    
    func generateOrder() {
        APIManager.generateOrder({ (responseDict) in
            self.parseOrderFromResponse(responseDict!)
            self.delegate?.didGenerateOrder?(true, error: nil)
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.delegate?.didGenerateOrder?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func fetchAvailableCoupons() {
        APIManager.fetchAvailableCoupons({ (responseDict) in
            self.parseCouponsFromResponse(responseDict!)
            self.delegate?.didFetchCoupons?(true, error: nil)
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.delegate?.didFetchCoupons?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func validateCoupon(code: String, amount: Double, userId: String, gymName: String, city: String, bookingType: String) {
        APIManager.validateCoupon(code, amount: amount, userId: userId, gymName: gymName, city: city, bookingType: bookingType, successCallback: { (responseDict) in
            debugPrint(responseDict)
            self.parseValidatedCoupon(responseDict!)
            self.delegate?.didValidateCoupon?(true, error: nil)
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.delegate?.didValidateCoupon?(false, error:APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func deleteItemFromCart(serviceId: String, scheduleID: String?, startDate: Double) {
        APIManager.deleteItemFromCart(serviceId, scheduleID: scheduleID, startDate: startDate, successCallback: { [weak self](responseDict) in
            if let responseArray = responseDict?[APIKeys.kCart]?[APIKeys.kItems] as? JSONArray {
                self?.parseCartFromResponse(responseArray)
                self?.delegate?.didUpdateItemsToCart?(true, error: nil)
                self?.invalidateCoupon()
            }
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.delegate?.didUpdateItemsToCart?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    
    func addItemToCart(serviceId: String, startDate: Double, scheduleId: String?) {
        APIManager.addItemToCart(serviceId, startDate: startDate, scheduleId: scheduleId, successCallback: { [weak self](responseDict) in
            if let responseArray = responseDict?[APIKeys.kCart]?[APIKeys.kItems] as? JSONArray {
                self?.parseCartFromResponse(responseArray)
                self?.delegate?.didUpdateItemsToCart?(true, error: nil)
                self?.invalidateCoupon()
            }
        }) { [weak self](errorReason, error) in
            debugPrint(errorReason)
            self?.delegate?.didUpdateItemsToCart?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    
    func placeOrder(walletAmount: Double, couponCode: String?) {
        APIManager.placeOrder(walletAmount, couponCode: couponCode, successCallback: { (responseDict) in
            debugPrint(responseDict)
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.delegate?.didPlaceOrder?(true, error: nil, orderStatus: responseDict![APIKeys.kOrderStatus] as? String, orderID: responseDict![APIKeys.kOrder]![APIKeys.kOrderID] as? String)
            }
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.delegate?.didPlaceOrder?(false, error: APIManager.errorForNetworkErrorReason(errorReason!), orderStatus: nil, orderID: nil)
        }
    }
    
    func didCompletePayment(success: Bool, error: NSError?) {
        if success {
            NSNotificationCenter.defaultCenter().postNotificationName(kPaymentCompleteNotification, object: nil, userInfo: nil)
            cartItems?.removeAll()
            delegate?.didCompletePayment?(true, error: nil)
            self.invalidateCoupon()
        }
        else {
            delegate?.didCompletePayment?(false, error: error)
        }
    }
    
    func invalidateCoupon() {
        couponCode = nil
        discount = 0.0
    }
    
    //MARK: Private Functions
    private func parseOrderFromResponse(responseDict: JSONDictionary) {
        if(responseDict[APIKeys.kStatusBool] as! Int == 1) {
            totalAmount = responseDict[APIKeys.kOrder]![APIKeys.kTotalAmount] as? Double
            orderId = responseDict[APIKeys.kOrder]![APIKeys.kOrderID] as? String
            parseCartFromResponse(responseDict[APIKeys.kOrder]![APIKeys.kItems] as! JSONArray)
        }
    }
    
    private func parseCartFromResponse(responseArray: JSONArray) {
        cartItems=nil
        for item in responseArray {
            let gymId = item[APIKeys.kGym]![APIKeys.kGymID] as? String ?? ""
            let gymName = item[APIKeys.kGym]![APIKeys.kGymName] as? String ?? ""
            let gymAddress = item[APIKeys.kGym]![APIKeys.kCity] as? String ?? ""
            let gymLogo = item[APIKeys.kGym]![APIKeys.kLogoURL] as? String ?? ""
            let serviceType = item[APIKeys.kService]![APIKeys.kServiceName] as? String ?? ""
            let scheduleId = item[APIKeys.kService]![APIKeys.kScheduleID] as? String
            let serviceId = item[APIKeys.kService]![APIKeys.kServiceID] as? String ?? ""
            let price = item[APIKeys.kPrice] as? Double ?? 0
            let startDate = item[APIKeys.kStartDate] as? Double ?? 0
            let endDate = item[APIKeys.kEndDate] as? Double
            let startTime = item[APIKeys.kStartTime] as? Double
            let endTime = item[APIKeys.kEndTime] as? Double
            let quantity = item[APIKeys.kQuantity] as? Int ?? 0
            let bookingType = item[APIKeys.kService]![APIKeys.kServiceType]!![APIKeys.kDesc] as? String ?? ""
            
            let gymDetails = CartItem(gymName: gymName, gymAddress: gymAddress, gymLogo: gymLogo, serviceType: serviceType, startDate: startDate, endDate: endDate, startTime: startTime, endTime: endTime, amount: price, quantity: quantity, serviceId: serviceId, scheduleId:scheduleId, bookingType: bookingType)
            
            var gymsArray = [CartItem]()
            
            if(cartItems==nil) {
                cartItems = [String:[CartItem]]()
            }
            if (cartItems?[gymId]) != nil {
                gymsArray = cartItems![gymId]! as [CartItem]
            }
            gymsArray.append(gymDetails)
            cartItems?[gymId] = gymsArray
        }
    }
    
    private func parseCouponsFromResponse(response: JSONDictionary) {
        coupons.removeAll()
        if(response[APIKeys.kStatusBool] as! Int == 1) {
            let coupons = response[APIKeys.kCoupons] as? JSONArray
            
            for coupon in coupons ?? [] {
                let name  = coupon[APIKeys.kCampaignName] as? String ?? ""
                let shortName = coupon[APIKeys.kName] as? String ?? ""
                let description = coupon[APIKeys.kDescription] as? String ?? ""
                let couponId = coupon[APIKeys.kCouponId] as? String ?? ""
                let details = Coupon(couponTitle: name, couponShortTitle: shortName, couponDescription: description, couponId: couponId)
                self.coupons.append(details)
            }
            delegate?.didFetchCoupons?(true, error: nil)
        }
    }
    
    private func parseValidatedCoupon(response: JSONDictionary) {
        if(response[APIKeys.kStatusBool] as! Int == 1) {
            couponCode = response[APIKeys.kCouponValue]![APIKeys.kCode] as? String
            discount = response[APIKeys.kCouponValue]![APIKeys.kDiscount] as? Double
        }
        else {
            couponCode=nil
            discount=nil
        }
        
    }
    
    
    
}
