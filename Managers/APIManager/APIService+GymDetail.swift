//
//  APIService+GymDetail.swift
//  BygApp
//
//  Created by Prince Agrawal on 25/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

enum GymDetailAPIService: APIService {
    
    case GetAllGyms(latitude: Double, longitude: Double, distance: Int?, page: Int?, size: Int?, filter: Bool?, category: [String]?, preferred: Bool?, popular: Bool?, rating: Int?, priceType: [Int]?)
    
    case GetGymByCategory(latitude: Double, longitude: Double, distance: Int?, page: Int?, size: Int, categoryID: String, filter: Bool?, category: [String]?, preferred: Bool?, popular: Bool?, rating: Int?, priceType: [Int]?)
    
    case GetServicesForGym(gymID: String, latitude: Double, longitude: Double)
    
    case searchGyms(searchText: String, lat: Double, lng: Double, distance: Double)
    
    case setRating(gymId: String, orderId: String, serviceId: String, rating: Double, comments: String?)
    
    case getRating(orderID: String)
    
    case GetOffers()
    
    case UpdateGymForm(name: String, address: String, comments: String?)
    
    var path: String {
        var path = ""
        switch self {
        case .GetAllGyms:
            path = BASE_API_URL.stringByAppendingString("/v1/fitness/services")
            
        case let .GetGymByCategory(_, _, _, _, _, categoryID, _, _, _, _, _, _):
            path = BASE_API_URL.stringByAppendingString("/v1/fitness/category/\(categoryID)")
        case let .GetServicesForGym(gymID, _, _):
            path = BASE_API_URL.stringByAppendingString("/v1/fitness/gym/services/\(gymID)")
            
        case .searchGyms:
            path = BASE_API_URL.stringByAppendingString("/v1/fitness/gym/search")
            
        case let .setRating(gymId,_,_,_,_):
            path = BASE_API_URL.stringByAppendingString("/v1/fitness/gym/ratings/\(gymId)")
            
        case let .getRating(orderID):
            path = BASE_API_URL.stringByAppendingString("/v1/fitness/gym/rating/\(orderID)")
            
        case .GetOffers:
            path = BASE_API_URL.stringByAppendingString("/v1/offers")
            
        case .UpdateGymForm:
            path = BASE_API_URL.stringByAppendingString("/v1/fitness/gym/request")
            
        }
        return path
    }
    
    var resource: Resource {
        var resource: Resource!
        switch self {
        case let .GetAllGyms(latitude, longitude, distance, page, size, filter, category, preferred, popular, rating, priceType):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kLat] = latitude
            parametersDict[APIKeys.kLng] = longitude
            parametersDict[APIKeys.kDistance] = distance
            parametersDict[APIKeys.kPage] = page
            parametersDict[APIKeys.kSize] = size
            parametersDict = GymDetailAPIService.paramsWithFilter(parametersDict, filter: filter, category: category, preferred: preferred, popular: popular, rating: rating, priceType: priceType)
            
            resource = Resource(method: .GET, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case let .GetGymByCategory(latitude, longitude, distance, page, size, _, filter, category, preferred, popular, rating, priceType):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kLat] = latitude
            parametersDict[APIKeys.kLng] = longitude
            parametersDict[APIKeys.kDistance] = distance
            parametersDict[APIKeys.kPage] = page
            parametersDict[APIKeys.kSize] = size
            parametersDict = GymDetailAPIService.paramsWithFilter(parametersDict, filter: filter, category: category, preferred: preferred, popular: popular, rating: rating, priceType: priceType)
            
            resource = Resource(method: .GET, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case let .GetServicesForGym(_,latitude, longitude):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kLat] = latitude
            parametersDict[APIKeys.kLng] = longitude
            resource = Resource(method: .GET, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case let .searchGyms(searchText, lat, lng, distance):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kTerm] = searchText
            parametersDict[APIKeys.kLat] = lat
            parametersDict[APIKeys.kLng] = lng
            parametersDict[APIKeys.kDistance] = distance
            
            resource = Resource(method: .GET, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case let .setRating(_, orderId, serviceId, rating, comments):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kOrderIDFull] = orderId
            parametersDict[APIKeys.kServiceID] = serviceId
            parametersDict[APIKeys.kRating] = rating
            parametersDict[APIKeys.kComment] = comments
            
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case .getRating(_):
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
        case .GetOffers:
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case let .UpdateGymForm(name, address, comments):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kName] = name
            parametersDict[APIKeys.kAddress] = address
            parametersDict[APIKeys.kComments] = comments
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
        }
        
        return resource
    }
    
    static func paramsWithFilter(paramsDict: JSONDictionary, filter: Bool?, category: [String]?, preferred: Bool?, popular: Bool?, rating: Int?, priceType: [Int]?) -> JSONDictionary {
        var dictionaryToReturn = paramsDict
        
        if let filter = filter {
            dictionaryToReturn[APIKeys.kFilter] = filter
        }
        
        if let category = category {
            var categoryString = ""
            for categoryID in category {
                categoryString = "\(categoryID),\(categoryString)"
                
            }
            categoryString = categoryString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ","))
            dictionaryToReturn[APIKeys.kCategory] = categoryString
        }
        
        if let preferred = preferred {
            dictionaryToReturn[APIKeys.kPreferred] = preferred
        }
        
        if let popular = popular {
            dictionaryToReturn[APIKeys.kPopular] = popular
        }
        
        if let rating = rating {
            dictionaryToReturn[APIKeys.kRating] = rating
        }
        
        if let priceType = priceType {
            var priceTypeString = ""
            for price in priceType {
                priceTypeString = "\(price),\(priceTypeString)"
            }
            priceTypeString = priceTypeString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: ","))
            dictionaryToReturn[APIKeys.kPriceClass] = priceTypeString
        }
        
        return dictionaryToReturn
    }

}

extension APIManager {
    class func getListOfGyms(latitude: Double, longitude: Double, distance: Int, page: Int, size: Int, filter: Bool?, category: [String]?, preferred: Bool?, popular: Bool?, rating: Int?, priceType: [Int]?, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                GymDetailAPIService.GetAllGyms(latitude:latitude, longitude: longitude, distance: distance, page: page, size: size, filter: filter, category: category, preferred: preferred, popular: popular, rating: rating, priceType: priceType).request(success: { (response) in
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
    
    class func getListOfGymsForCategory(latitude: Double, longitude: Double, distance: Int, page: Int, size: Int, categoryID: String, filter: Bool?, category: [String]?, preferred: Bool?, popular: Bool?, rating: Int?, priceType: [Int]?, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                GymDetailAPIService.GetGymByCategory(latitude:latitude, longitude: longitude, distance: distance, page: page, size: size, categoryID: categoryID, filter: filter, category: category, preferred: preferred, popular: popular, rating: rating, priceType: priceType).request(success: { (response) in
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
    
    class func getServicesForGym(gymID: String, latitude: Double, longitude: Double, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                GymDetailAPIService.GetServicesForGym(gymID: gymID, latitude: latitude, longitude: longitude).request(success: { (response) in
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
    
    class func fetchSearchGyms(searchText: String,latitude: Double, longitude: Double, distance: Double, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                GymDetailAPIService.searchGyms(searchText: searchText, lat: latitude, lng: longitude, distance: distance).request(success: { (response) in
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
    
    class func setRating(gymId: String, orderId: String, serviceId: String, rating: Double, comments: String?, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                GymDetailAPIService.setRating(gymId: gymId, orderId: orderId, serviceId: serviceId, rating: rating, comments: comments).request(success: { (response) in
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
    
    class func getRating(orderID: String, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                GymDetailAPIService.getRating(orderID: orderID).request(success: { (response) in
                    debugPrint(response)
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
    
    class func getOffers(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                GymDetailAPIService.GetOffers().request(success: { (response) in
                    debugPrint(response)
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
    
    class func updateGymForm(name: String, address: String, comments: String?=nil, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                GymDetailAPIService.UpdateGymForm(name: name, address: address, comments: comments).request(success: { (response) in
                    debugPrint(response)
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