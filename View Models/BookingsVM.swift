//
//  BookingsVM.swift
//  BygApp
//
//  Created by Prince Agrawal on 21/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

@objc protocol BookingVMDelegate {
    optional func didFetchMeCardsWithError(success: Bool, error: NSError?)
    optional func  didFetchBookingHistoryWithError(success: Bool, error: NSError?)
    optional func didFetchRatingSuccess(success: Bool, error: NSError?, rating: Double)
    optional func didRatingSubmittedSuccessFullyWithRating(success: Bool, error: NSError?, rating: Double)
}


class BookingsVM {
    
    struct MeCard {
        var gymName: String
        var gymAddress: String
        var gymLogoURL: String?
        var serviceName: String
        var detail1: String
        var detail2: String?
        var rating: Float?
        var gymLatitude: Double?
        var gymLongitude: Double?
        var specialInstructions: String?
        var gymNumber: String?
        var orderId: String
        var serviceId: String
        var gymId: String
        var endDate: NSDate
    }
    
    struct BookedGymDetails {
        var gymName: String
        var gymAddress: String
        var gymLogoURL: String?
        var serviceName: String
        var detail1: String
        var detail2: String?
        var detail1Title: String
        var detail2Title: String
    }
    
    
    struct Booking {
        var orderID: String!
        var title: String!
        var gyms: [BookedGymDetails]!
        var bookedDate: Double!
        var totalAmount: Double!
        var walletAmount: Double!
        var paidAmount: Double!
    }
    

    
    var meCards = [MeCard]()
    var bookings = [Booking]()
    weak var delegate: BookingVMDelegate?
    
    
    
    //MARK: API calls
    
    func getBookingsHistory() {
        APIManager.getBookings({ [weak self](responseDict) in
            self?.bookings.removeAll()
            debugPrint(responseDict)
            if let orders = responseDict?[APIKeys.kOrders] as? JSONArray {
                self?.parseBookingHistoryFromResponse(orders)
                self?.delegate?.didFetchBookingHistoryWithError?(true, error: nil)
            }
        }) { (errorReason, error) in
            self.delegate?.didFetchBookingHistoryWithError?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func getMeCards() {
        APIManager.getMeCards({ [weak self](responseDict) in
            self?.meCards.removeAll()
            if let orders = responseDict?[APIKeys.kOrders] as? JSONArray {
                self?.parseMeCardsFromNewResponse(orders)
                self?.delegate?.didFetchMeCardsWithError?(true, error: nil)
            }
        }) { (errorReason, error) in
            self.delegate?.didFetchMeCardsWithError?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    
    func getRatings(orderID: String) {
        
        APIManager.getRating(orderID, successCallback: { (responseDict) in
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                let ratingDict = responseDict![APIKeys.kRating] as? JSONDictionary
                if(ratingDict?.count>0) {
                    if let rating =  ratingDict?[APIKeys.kRating] as? Double {
                        self.delegate?.didFetchRatingSuccess?(true, error: nil, rating: rating)
                    }
                }
                else {
                    self.delegate?.didFetchRatingSuccess?(true, error: nil, rating: 0)
                }
            }
            }) { (errorReason, error) in
                self.delegate?.didFetchRatingSuccess?(false, error: APIManager.errorForNetworkErrorReason(errorReason!), rating: 0)
        }
    }
    
    func setRating(gymId: String, orderId: String, serviceId: String, rating: Double, comments: String?) {
        APIManager.setRating(gymId, orderId: orderId, serviceId: serviceId, rating: rating, comments: comments, successCallback: { (responseDict) in
            if(responseDict!["status"] as! Int == 1) {
                self.delegate?.didRatingSubmittedSuccessFullyWithRating?(true, error: nil, rating: rating)
            }
            }) { (errorReason, error) in
                self.delegate?.didRatingSubmittedSuccessFullyWithRating?(false, error: APIManager.errorForNetworkErrorReason(errorReason!), rating: 0)
        }
    }
    
    
    //MARK: Private Functions
    private func parseMeCardsFromNewResponse(responseArray: JSONArray) {
        for meCardDict in responseArray {
            var gymName, gymAddress, gymLogo , serviceName, phoneNumber,gymId , detail1, detail2: String?
            var latitude,longitude: Double?
            var expiredDate: NSDate?
            
            var rating: Float?
            if let gymDict = meCardDict[APIKeys.kGym] as? JSONDictionary {
                gymName = gymDict[APIKeys.kName] as? String
                gymId = gymDict[APIKeys.kID] as? String
                gymAddress = gymDict[APIKeys.kAddress] as? String
                gymLogo = gymDict[APIKeys.kLogoURL] as? String
                latitude = gymDict[APIKeys.kLat] as? Double
                longitude = gymDict[APIKeys.kLng] as? Double
                phoneNumber = gymDict[APIKeys.kPhone] as? String
                rating = gymDict[APIKeys.kRating] as? Float
            }
            serviceName = meCardDict[APIKeys.kServiceName] as? String
            let startTime = meCardDict[APIKeys.kStartTime] as? Double
            let endTime = meCardDict[APIKeys.kEndTime] as? Double
            let endDate = meCardDict[APIKeys.kEndDate] as? Double
            let startDate = meCardDict[APIKeys.kStartDate] as? Double
            detail1 = "\(startDate!.bygDateString())"
            let endDateString = endDate?.bygDateString()
            if(endDate != nil) {
                if(endDateString != detail1) {
                    expiredDate = NSDate(timeIntervalSince1970: endDate!/1000.0)
                    detail1 = "\(detail1!) to \(endDate!.bygDateString())"
                }
            }
            if(startTime != nil) {
                detail2 = "\(startTime!.bygTimeString())"
                
                if(endTime != nil) {
                    
                   expiredDate = mergeDates(NSDate(timeIntervalSince1970: startDate!/1000.0), time: NSDate(timeIntervalSince1970: endTime!/1000.0))
                    detail2 = "\(detail2!) to \(endTime!.bygTimeString())"
                }
            }
            let orderId = meCardDict[APIKeys.kOrderIDFull] as? String ?? ""
            let serviceId = meCardDict[APIKeys.kServiceID] as? String ?? ""
            let meCard = MeCard(gymName: gymName!, gymAddress: gymAddress!, gymLogoURL: gymLogo, serviceName: serviceName!, detail1: detail1!, detail2: detail2, rating: rating, gymLatitude: latitude, gymLongitude: longitude, specialInstructions: nil, gymNumber: phoneNumber, orderId: orderId, serviceId: serviceId, gymId: gymId!, endDate: expiredDate!)
            meCards.append(meCard)
            print(meCards)
        }
        meCards = meCards.reverse()
    }
    
    
    private func parseBookingHistoryFromResponse(responseArray: JSONArray) {
        for bookingDict in responseArray {
            var detail1 = ""
            var detail2 = ""
            var detail1Title = ""
            var detail2Title = ""
            var title = ""
            let orderId = bookingDict[APIKeys.kOrderID] as? String ?? ""
            let bookingDate = bookingDict[APIKeys.kBookedOn] as? Double ?? 0
            let totalAmount = bookingDict[APIKeys.kTotalAmount] as? Double ?? 0
            let walletAmount = bookingDict[APIKeys.kWalletAmount] as? Double ?? 0
            let paidAmount = bookingDict[APIKeys.kPaidAmount] as? Double ?? 0
            let gyms = bookingDict[APIKeys.kSubOrders] as? JSONArray
            var membershipCount = Int()
            var workoutCount = Int()
            var gymsArray = [BookedGymDetails]()
            for gym in gyms ?? [] {
                let gymName = gym[APIKeys.kGym]![APIKeys.kGymName] as? String ?? ""
                let gymAddress = gym[APIKeys.kGym]![APIKeys.kCity] as? String ?? ""
                let logoUrl = gym[APIKeys.kGym]![APIKeys.kLogoURL] as? String ?? ""
                
                let serviceName = gym[APIKeys.kServiceName] as? String
                
                if serviceName!.containsString(kMembership) {
                    let startDate = gym[APIKeys.kStartDate] as? Double ?? 0
                    let endDate = gym[APIKeys.kEndDate] as? Double ?? 0
                    membershipCount += 1
                    detail1Title = "Start Date:"
                    detail2Title = "End Date:"
                    detail1 = startDate.bygDateString()
                    detail2 = endDate.bygDateString()
                }
                else {
                    detail2Title=String()
                    detail2=String()
                    let startTime = gym[APIKeys.kStartTime] as? Double
                    let endTime = gym[APIKeys.kEndTime] as? Double
                    let startDate = gym[APIKeys.kStartDate] as? Double
                    workoutCount += 1
                    detail1Title = "Slot Date:"
                    detail1 = "\(startDate!.bygDateString())"
                    if(startTime != nil) {
                        detail2Title = "Slot Time:"
                        detail2 = "\(startTime!.bygTimeString()) to \(endTime!.bygTimeString())"
                    }
                }
                
                let gymDetails = BookedGymDetails(gymName: gymName, gymAddress: gymAddress, gymLogoURL: logoUrl, serviceName: serviceName!, detail1: detail1, detail2: detail2, detail1Title: detail1Title, detail2Title: detail2Title)
                gymsArray.append(gymDetails)
            }
            if(membershipCount>0) {
                title = "\(membershipCount) Memberships"
            }
            if(workoutCount>0) {
                if(title == "") {
                    title = "\(workoutCount) Workout sessions"
                }
                else {
                    title = "\(title) and \(workoutCount) Workout sessions"
                }
            }
            let booking = Booking(orderID: orderId, title: title, gyms: gymsArray, bookedDate: bookingDate, totalAmount: totalAmount, walletAmount: walletAmount, paidAmount: paidAmount)
            bookings.append(booking)
        }
    }
    
    private func mergeDates(date: NSDate, time: NSDate) -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([.Day , .Month , .Year], fromDate: date)
        let timeComponents = calendar.components([.Hour , .Minute , .Second], fromDate: time)
        
        let newComponents = NSDateComponents()
        newComponents.day = dateComponents.day
        newComponents.month = dateComponents.month
        newComponents.year = dateComponents.year
        newComponents.hour = timeComponents.hour
        newComponents.minute = timeComponents.minute
        newComponents.second = timeComponents.second
        
        print(calendar.dateFromComponents(newComponents)!)
        return calendar.dateFromComponents(newComponents)!
    }

    
    
}