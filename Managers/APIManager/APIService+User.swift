//
//  APIManager+UserProfile.swift
//  BygApp
//
//  Created by Manish on 30/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

enum UserAPIServices: APIService {
    
    case GetUserDetails()
    
    case UpdateContactForm(firstName: String?, email: String?, phoneNumber: String?, countryCode: String?, countryIso: String?)
    
    case UpdateNotifications()
    
    case ValidateReferal(referralCode: String)
    
    case UpdateProfile(name: String?, phoneNumber:NSDictionary?, gender: String?, dob: String?, email: String?, corporateEmail: String?, height: NSDictionary?, weight: NSDictionary?, idealWeight: NSDictionary?, lifestyle: String?, workoutExperience: Bool?, goal: [String]?, fitnessLevel: String?, preferredWorkout: [String]?, relation: String?, fbData: String?)
    
    case UploadProfileImage()
    
    case ValidateOTP(code: String)
    
    case ResendOTP()
    
    case SendOTP()
    
    case SendEmailVerification(email: String)
    
    
    var path: String {
        var path = ""
        switch self {
        case .GetUserDetails:
            path = BASE_API_URL.stringByAppendingString("/v1/user/profile")
        case .UpdateContactForm:
            path = BASE_API_URL.stringByAppendingString("/v1/user/contact")
        case .UpdateNotifications:
            path = BASE_API_URL.stringByAppendingString("/v1/user/preferences")
        case .ValidateReferal:
            path = BASE_API_URL.stringByAppendingString("/v1/user/referral")
        case .UpdateProfile:
            path = BASE_API_URL.stringByAppendingString("/v1/user/profile")
        case .UploadProfileImage:
            path = BASE_API_URL.stringByAppendingString("/v1/user/profile/pic")
        case .ValidateOTP:
            path = BASE_API_URL.stringByAppendingString("/v1/user/otp/verification")
        case .ResendOTP:
            path = BASE_API_URL.stringByAppendingString("/v1/user/phone/verification/resend")
        case .SendOTP:
            path = BASE_API_URL.stringByAppendingString("/v1/user/phone/verification")
        case .SendEmailVerification:
            path = BASE_API_URL.stringByAppendingString("/v1/user/email/verification")
        }
        return path
    }
    
    var resource: Resource {
        var resource: Resource!
        switch self {
            
        case .GetUserDetails():
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case let .UpdateContactForm(firstName, email, phoneNumber, countryCode, countryIso):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kfirstName] = firstName
            parametersDict[APIKeys.kEmail] = email
            parametersDict[APIKeys.kPhoneNumber] = phoneNumber
            parametersDict[APIKeys.kCountryCode] = countryCode
            parametersDict[APIKeys.kCountryIso] = countryIso
            resource = Resource(method: .PUT, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case .UpdateNotifications():
            var parametersDict = JSONDictionary()
            for (key,value) in UserDataModel.notificationsDictionary {
                parametersDict[key] = value
            }
            resource = Resource(method: .PUT, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case let .ValidateReferal(referralCode):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kReferalCode] = referralCode
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
        case let .UpdateProfile(name, phoneNumber, gender, dob, email, corporateEmail, height, weight, idealWeight, lifestyle, workoutExperience, goal, fitnessLevel, preferredWorkout, relation, fbData):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kName] = name
            parametersDict[APIKeys.kPhoneNumber] = phoneNumber
            parametersDict[APIKeys.kGender] = gender
            parametersDict[APIKeys.kDob] = dob
            parametersDict[APIKeys.kEmail] = email
            parametersDict[APIKeys.kCorporateEmail] = corporateEmail
            parametersDict[APIKeys.kHeight] = height
            parametersDict[APIKeys.kWeight] = weight
            parametersDict[APIKeys.kIdealWeight] = idealWeight
            parametersDict[APIKeys.kLifeStyle] = lifestyle
            parametersDict[APIKeys.kWorkoutExperience] = workoutExperience
            parametersDict[APIKeys.kGoals] = goal
            parametersDict[APIKeys.kFitnessLevel] = fitnessLevel
            parametersDict[APIKeys.kPreferredWorkout] = preferredWorkout
            parametersDict[APIKeys.kRelation] = relation
            parametersDict[APIKeys.kFbData] = fbData
            
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case .UploadProfileImage:
            resource = Resource(method: .POST, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case let .ValidateOTP(code):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kCode] = code
            
            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case .ResendOTP:
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case .SendOTP:
            resource = Resource(method: .GET, parameters: nil, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])
            
        case let .SendEmailVerification(email):
            var parametersDict = JSONDictionary()
            parametersDict[APIKeys.kEmail] = email

            resource = Resource(method: .POST, parameters: parametersDict, headers: [APIKeys.kAuthorizationHeader
                :"Bearer \(DataManager.jwtToken!)"])

        }
        return resource
    }
}

extension APIManager {
    
    class func getUserDetails(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.GetUserDetails().request(success:{ (response) in
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
    
    class func updateContactForm(firstName: String?, email: String?, phoneNumber: String?, countryCode: String?, countryIso: String?, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.UpdateContactForm(firstName: firstName, email: email, phoneNumber: phoneNumber, countryCode: countryCode, countryIso: countryIso).request(success:{ (response) in
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
    
    class func updateNotifications(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.UpdateNotifications().request(success:{ (response) in
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
    
    class func validateReferalCode(referalCode: String, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.ValidateReferal(referralCode: referalCode).request(success:{ (response) in
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
    
    class func updateUserProfile(name: String?, phoneNumber:NSDictionary?, gender: String?, dob: String?, email: String?, corporateEmail: String?, height: NSDictionary?, weight: NSDictionary?, idealWeight: NSDictionary?, lifestyle: String?, workoutExperience: Bool?, goal: [String]?, fitnessLevel: String?, preferredWorkout: [String]?, relation: String?, fbData: String?, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.UpdateProfile(name: name, phoneNumber: phoneNumber, gender: gender, dob: dob, email: email, corporateEmail: corporateEmail, height: height, weight: weight, idealWeight: idealWeight, lifestyle: lifestyle, workoutExperience: workoutExperience, goal: goal, fitnessLevel: fitnessLevel, preferredWorkout: preferredWorkout, relation: relation, fbData: fbData).request(success:{ (response) in
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
    
    class func uploadProfileImage(imageData: NSData, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.UploadProfileImage().upload(imageData, success: { (response) in
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
    
    class func validateOTP(code: String, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.ValidateOTP(code: code).request(success:{ (response) in
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
    
    class func resentOTP(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.ResendOTP().request(success:{ (response) in
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
    
    class func sendOTP(successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.SendOTP().request(success:{ (response) in
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
    
    class func sendEmailVerification(email: String, successCallback: JSONDictionaryResponseCallback, failureCallback: APIServiceFailureCallback) {
        validateToken( { (isSuccess: Bool) in
            if isSuccess {
                UserAPIServices.SendEmailVerification(email: email).request(success:{ (response) in
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
