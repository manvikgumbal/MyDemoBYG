//
//  APIService+Onboarding.swift
//  BygApp
//
//  Created by Manish on 20/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

enum OnboardingAPIService: APIService {
    
    case FacebookLogin(firstName: String, email: String?, phone: String?, socialId: String, provider:String, platform:String, phoneModel: String?, osVersion:String?, deviceToken: String?)
    case PhoneLogin(phoneNumber: String, platform: String, phoneModel: String?, osVersion: String?, deviceToken: String?, countryCode: String, countryIso: String)
    
    case FetchLocation(searchText:String)
    case RefreshToken()
    
    case FetchAddress(lat: Double, lng: Double)
    case FetchNearbyGyms(latitude: Double, longitude: Double, distance: Float)
    case getHTMLData(dataType: String)
    
    var path: String {
        var path = ""
        switch self {
        case .FacebookLogin:
            path = BASE_API_URL.stringByAppendingString("/v1/user/social/login")
            
        case .PhoneLogin:
            path = BASE_API_URL.stringByAppendingString("/v1/user/phone/login")
            
        case .FetchLocation:
            path = BASE_API_URL.stringByAppendingString("/v1/location/search")
            
        case .RefreshToken:
            path = BASE_API_URL.stringByAppendingString("/v1/user/token/refresh/\(DataManager.refreshToken!)")
            
        case .FetchAddress:
            path  = BASE_API_URL.stringByAppendingString("/v1/location/address/search")
            
        case .FetchNearbyGyms:
            path = BASE_API_URL.stringByAppendingString("/v1/fitness/map")
            
        case let .getHTMLData(dataType):
            path = BASE_API_URL.stringByAppendingString("/v1/company/\(dataType)")
        }
        return path
    }
    
    var resource: Resource {
        var resource: Resource!
        switch self {
        case let .FacebookLogin(firstName, email, phone, socialId, provider, platform, phoneModel, osVersion, deviceToken):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kfirstName] = firstName
            parametersDict[APIKeys.kEmail] = email
            parametersDict[APIKeys.kPhoneNumber] = phone
            parametersDict[APIKeys.kSocialID] = socialId
            parametersDict[APIKeys.kProvider] = provider
            parametersDict[APIKeys.kPlatform] = platform
            parametersDict[APIKeys.kPhoneModel] = phoneModel
            parametersDict[APIKeys.kOSVersion] = osVersion
            parametersDict[APIKeys.kDeviceToken] = deviceToken
            resource = Resource(method: .POST, parameters: parametersDict, headers: [:])
            
        case let .PhoneLogin(phoneNumber, platform, phoneModel, osVersion, deviceToken, countryCode, countryIso):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kPhoneNumber] = phoneNumber
            parametersDict[APIKeys.kPlatform] = platform
            parametersDict[APIKeys.kPhoneModel] = phoneModel
            parametersDict[APIKeys.kOSVersion] = osVersion
            parametersDict[APIKeys.kDeviceToken] = deviceToken
            parametersDict[APIKeys.kCountryCode] = countryCode
            parametersDict[APIKeys.kCountryIso] = countryIso
            
            resource = Resource(method: .POST, parameters: parametersDict, headers: [:])
            
            
            
        case let .FetchLocation(searchText):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kSearch] = searchText
            
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case .RefreshToken():
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case let .FetchAddress(lat, lng):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kLat] = lat
            parametersDict[APIKeys.kLng] = lng
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case let .FetchNearbyGyms(latitude, longitude, distance):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kLat] = latitude
            parametersDict[APIKeys.kLng] = longitude
            parametersDict[APIKeys.kDistance] = distance
            resource = Resource(method: .GET, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
        case .getHTMLData(_):
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader:"Bearer \(DataManager.jwtToken!)"])
            
            
        }
        return resource
    }
}

extension APIManager {
    class func loginWithFacebook(firstName: String, email: String? = nil, phone: String? = nil, socialId: String, provider:String, platform:String, phoneModel: String? = nil, osVersion:String? = nil, deviceToken: String? = nil, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        OnboardingAPIService.FacebookLogin(firstName: firstName, email: email, phone: phone, socialId: socialId, provider: provider, platform: platform, phoneModel: phoneModel, osVersion: osVersion, deviceToken: deviceToken).request(success:{(response) -> () in
            
            if let responseDict = response as? JSONDictionary {
                updateAuthTokenDetails(responseDict)
            }
            successCallback([:])
            }, failure: failureCallback)
    }
    
    class func fetchLocation(searchText: String, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                OnboardingAPIService.FetchLocation(searchText: searchText).request(success:{ (response) in
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
    
    class func loginWithPhone(phoneNumber: String, platform: String, phoneModel: String?=nil, osVersion: String?=nil, deviceToken: String?=nil, countryCode: String, countryIso: String, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        
        OnboardingAPIService.PhoneLogin(phoneNumber: phoneNumber, platform: platform, phoneModel: phoneModel, osVersion: osVersion, deviceToken: deviceToken, countryCode: countryCode, countryIso: countryIso).request(success: {(response) -> () in
            if let responseDict = response as? JSONDictionary {
                updateAuthTokenDetails(responseDict)
            }
            successCallback([:])
            }, failure: failureCallback)
    }
    
    class func getHTMLData(dataType: String, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        OnboardingAPIService.getHTMLData(dataType: dataType).request(success: {(response) -> () in
            if let responseDict = response as? JSONDictionary {
                successCallback(responseDict)
            }
            else {
                successCallback([:])
            }
            }, failure: failureCallback)
    }
    
    
    class func fetchAddress(latitude: Double, longitude: Double, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                OnboardingAPIService.FetchAddress(lat: latitude, lng: longitude).request(success:{ (response) in
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
    
    class func fetchNearGyms(latitude: Double, longitude: Double, distance: Float, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                OnboardingAPIService.FetchNearbyGyms(latitude: latitude, longitude: longitude, distance: distance).request(success:{ (response) in
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

