//
//  UsersVM.swift
//  BygApp
//
//  Created by Manish on 30/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

@objc protocol UsersVMDelegate {
    optional func didFetchUserProfile(success: Bool, error: NSError?)
    optional func didUpdateContact(success: Bool, error: NSError?)
    optional func didUpdateNotificationSettings(success: Bool, error: NSError?)
    optional func didValidateReferralCode(success: Bool, error: NSError?)
    optional func didUpdateProfileImage(success: Bool, error: NSError?)
    optional func didPhoneVerification(success: Bool, error: NSError?)
    optional func didResendOTP(success: Bool, error: NSError?)
    optional func didSentOTP(success: Bool, error: NSError?)
    optional func didEmailVerificationSent(success: Bool, error: NSError?)
}

@objc protocol UpdateProfileDelegate {
    func didUpdateProfile(success: Bool, error: NSError?, phoneVerification: Bool)
}

class UsersVM {
    
    static let sharedInstance = UsersVM()
    private init() {}
    
    weak var delegate: UsersVMDelegate?
    weak var updateProfileDelegate: UpdateProfileDelegate?
    
    //MARK: Call API's
    func getUserDetails() {
        APIManager.getUserDetails({ (resposeDict) in
            self.parseUserProfileResponse(resposeDict!)
            self.delegate?.didFetchUserProfile?(true, error: nil)
            }) { (errorReason, error) in
                self.delegate?.didFetchUserProfile?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func logoutTheUser() {
        PhoneLoginSuite.sharedInstance.logout()
        let facebookLoginSuite = FacebookLoginSuite()
        facebookLoginSuite.logout()
        
        //Clear Auth Tokens
        DataManager.jwtToken=nil
        DataManager.jwtExpiryDate=nil
        DataManager.refreshToken=nil
        
        UsersVM.sharedInstance.removeUserData()
        
        let storyBoard = UIStoryboard(storyboard: .Main)
        let initialController = storyBoard.instantiateViewController() as MainVC
        let navController = UINavigationController()
        navController.setViewControllers([initialController], animated: true)
        navController.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().keyWindow?.rootViewController = navController
    }
    
    
    func callAPIToUpdateContactForm(firstName: String?, email: String?, phoneNumber: String?, countryCode: String?, countryIso: String?) {
        APIManager.updateContactForm(firstName, email: email, phoneNumber: phoneNumber, countryCode: countryCode, countryIso: countryIso, successCallback: { (responseDict) in
            self.parseUserProfileResponse(responseDict!)
            self.delegate?.didUpdateContact?(true, error: nil)
            }) { (errorReason, error) in
                self.delegate?.didUpdateContact?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func callAPIToUpdateNotifications() {
        APIManager.updateNotifications({ (responseDict) in
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.delegate?.didUpdateNotificationSettings?(true, error:nil)
            }
            }) { (errorReason, error) in
                self.delegate?.didUpdateNotificationSettings?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func callAPIToCheckReferalCode(referalCode: String) {
        APIManager.validateReferalCode(referalCode, successCallback: { (responseDict) in
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.parseUserProfileResponse(responseDict!)
                self.delegate?.didValidateReferralCode?(true, error: nil)
            }
            }) { (errorReason, error) in
                debugPrint(errorReason)
                self.delegate?.didValidateReferralCode?(false, error:  APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    
    func callAPIToUpdateProfile() {
        var phoneNumberDict: NSMutableDictionary?
        print(UserDataModel.userDetailsDictionary[kPhoneNumber])
        if(UserDataModel.userDetailsDictionary[kPhoneNumber] as! String == "") {
            phoneNumberDict = nil
        }
        else {
          phoneNumberDict  = [APIKeys.kCountryCode: "91", APIKeys.kCountryIso: "IN", APIKeys.kNumber: UserDataModel.userDetailsDictionary[kPhoneNumber]!]
        }
        
        var email, corporateEmail: String?
        
        if(UserDataModel.userDetailsDictionary[kEmail] as! String != "") {
            email = UserDataModel.userDetailsDictionary[kEmail] as? String
        }
        
        if(UserDataModel.userDetailsDictionary[kCorporateEmail] as! String != "") {
            corporateEmail = UserDataModel.userDetailsDictionary[kCorporateEmail] as? String
        }
        
        var heightDict: NSDictionary?
        if(UserDataModel.HeightDict[kHeight]=="") {
            heightDict=nil
        }
        else {
         heightDict = [APIKeys.kValue: Double(UserDataModel.HeightDict[kHeight]!)!, APIKeys.kUnit: UserDataModel.HeightDict[kUnit]!]
        }
        
        var weightDict: NSDictionary?
        if(UserDataModel.WeightDict[kWeight]=="") {
            weightDict=nil
        }
        else {
            weightDict = [APIKeys.kValue: Double(UserDataModel.WeightDict[kWeight]!)!, APIKeys.kUnit: UserDataModel.WeightDict[kUnit]!]
            
        }
        
        var idealWeightDict: NSDictionary?
        idealWeightDict = nil

        var goalArray: [String]?
        
        for (key,value) in UserDataModel.GoalDict {
            if(goalArray==nil) {
                goalArray = [String]()
            }
            if(value==true) {
                goalArray?.append(key)
            }
        }
        
        var preferredWorkoutArray: [String]?
        
        for (key,value) in UserDataModel.PreferredWorkoutDict {
            if(preferredWorkoutArray==nil) {
                preferredWorkoutArray = [String]()
            }
            if(value==true) {
                preferredWorkoutArray?.append(key)
            }
        }
        
        APIManager.updateUserProfile(UserDataModel.userDetailsDictionary[kUserName] as? String, phoneNumber: phoneNumberDict, gender: UserDataModel.userDetailsDictionary[kGender] as? String, dob: nil, email: email, corporateEmail: corporateEmail, height: heightDict, weight: weightDict, idealWeight: idealWeightDict, lifestyle: UserDataModel.LifeStyleArray[UserDataModel.LifeStyleSelectedIndex], workoutExperience: UserDataModel.userDetailsDictionary[kWorkoutExperience] as? Bool, goal: goalArray, fitnessLevel: UserDataModel.FitnessLevelArray[UserDataModel.FitnessLevelSelectedIndex], preferredWorkout: preferredWorkoutArray, relation: nil, fbData: nil, successCallback: { (responseDict) in
            debugPrint(responseDict)
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.parseUserProfileResponse(responseDict!)
                responseDict
                self.updateProfileDelegate?.didUpdateProfile(true, error: nil, phoneVerification: responseDict![APIKeys.kPhoneVerification] as? Bool ?? false)
            }
            }) { (errorReason, error) in
                debugPrint(errorReason)
                self.updateProfileDelegate?.didUpdateProfile(false, error:  APIManager.errorForNetworkErrorReason(errorReason!), phoneVerification: false)
        }
    }
    
    func callAPIToUploadImage(imageData: NSData) {
        APIManager.uploadProfileImage(imageData, successCallback: { (responseDict) in
            debugPrint(responseDict)
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.delegate?.didUpdateProfileImage!(true, error: nil)
            }            
            self.parseUserProfileResponse(responseDict!)
            }) { (errorReason, error) in
                debugPrint(errorReason)
                self.delegate?.didUpdateProfileImage!(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
                
        }
    }
    
    func callAPIToValidateOTP(code: String) {
        APIManager.validateOTP(code, successCallback: { (responseDict) in
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.delegate?.didPhoneVerification!(true, error: nil)
            }
            }) { (errorReason, error) in
                self.delegate?.didPhoneVerification!(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    
    func callAPIToResendOTP() {
        APIManager.resentOTP({ (responseDict) in
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.delegate?.didResendOTP!(true, error: nil)
            }
            }) { (errorReason, error) in
                self.delegate?.didResendOTP!(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func callAPIToSendOTP() {
        APIManager.sendOTP({ (responseDict) in
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.delegate?.didSentOTP!(true, error: nil)
            }
        }) { (errorReason, error) in
            self.delegate?.didSentOTP!(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func callAPIToVerifyEmail(email: String) {
        
        APIManager.sendEmailVerification(email, successCallback: { (responseDict) in
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.delegate?.didEmailVerificationSent!(true, error: nil)
            }
        }) { (errorReason, error) in
            self.delegate?.didEmailVerificationSent!(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    
    func removeUserData() {
        //Clear User Data
        UserDataModel.userDetailsDictionary[kUserName]=""
        UserDataModel.userDetailsDictionary[kUserId]=""
        UserDataModel.userDetailsDictionary[kEmail]=""
        UserDataModel.userDetailsDictionary[kEmailVerified]=false
        UserDataModel.userDetailsDictionary[kCorporateEmailVerified]=false
        UserDataModel.userDetailsDictionary[kPhoneNumberVerified]=false
        UserDataModel.userDetailsDictionary[kImageURLString]=""
        UserDataModel.userDetailsDictionary[kPhoneNumber]=""
        UserDataModel.userDetailsDictionary[kWalletAmount]=0.0
        UserDataModel.userDetailsDictionary[kReferalCode]=""
        UserDataModel.userDetailsDictionary[kReferredBy]=0.0
        UserDataModel.userDetailsDictionary[kCorporateEmail]=""
        UserDataModel.userDetailsDictionary[kLifeStyle]=""
        UserDataModel.userDetailsDictionary[kFitnessLevel]=""
        UserDataModel.userDetailsDictionary[kRelation]=""
        UserDataModel.userDetailsDictionary[kGender]="M"
        UserDataModel.userDetailsDictionary[kWorkoutExperience]=false
        
        
        for (key,_) in UserDataModel.GoalDict {
            UserDataModel.GoalDict[key] = false
        }
        
        for (key,_) in UserDataModel.PreferredWorkoutDict {
            UserDataModel.PreferredWorkoutDict[key] = false
        }
        
        UserDataModel.HeightDict[kHeight] = ""
        UserDataModel.HeightDict[kUnit] = "cms"
        UserDataModel.WeightDict[kWeight] = ""
        UserDataModel.WeightDict[kUnit] = "kgs"
    }
    
    
    // MARK: Private Functions
    
    private func parseUserProfileResponse(responseDict: JSONDictionary) {
        debugPrint(responseDict)
        if(responseDict[APIKeys.kStatusBool] as! Int == 1) {
            
            if let emails = responseDict[APIKeys.kUser]![APIKeys.kEmail] as? JSONArray {
                for email in emails {
                    if let preference = email[APIKeys.kPreference] as? String {
                        if(preference.containsString(kPrimary)) {
                            let emailAddress = email[APIKeys.kAddress] as? String ?? ""
                            let emailVerified = email[APIKeys.kIsVerified] as? Bool ?? false
                            UserDataModel.userDetailsDictionary.updateValue(emailAddress, forKey: kEmail)
                            UserDataModel.userDetailsDictionary.updateValue(emailVerified, forKey: kEmailVerified)
                        }
                        if(preference.containsString(kCorporate)) {
                            let corporateEmail = email[APIKeys.kAddress] as? String ?? ""
                            let emailVerified = email[APIKeys.kIsVerified] as? Bool ?? false
                            UserDataModel.userDetailsDictionary.updateValue(corporateEmail, forKey: kCorporateEmail)
                            UserDataModel.userDetailsDictionary.updateValue(emailVerified, forKey: kCorporateEmailVerified)
                        }
                    }
                }
            }
            let name = responseDict[APIKeys.kUser]![APIKeys.kfirstName] as? String
            if(name != nil) {
                UserDataModel.userDetailsDictionary.updateValue(name!, forKey: kUserName)
            }
            if let phoneNumber = responseDict[APIKeys.kUser]![APIKeys.kPhoneNumber] as? JSONDictionary {
                let number = phoneNumber[APIKeys.kNumber] as? String
                let isVerified = phoneNumber[APIKeys.kIsVerified] as? Bool
                UserDataModel.userDetailsDictionary.updateValue(number!, forKey: kPhoneNumber)
                UserDataModel.userDetailsDictionary.updateValue(isVerified!, forKey: kPhoneNumberVerified)
            }
            if let referredBy = responseDict[APIKeys.kUser]![APIKeys.kReferredBy] as? JSONDictionary {
                UserDataModel.userDetailsDictionary[kReferredBy] = referredBy[APIKeys.kAmount] as? Double
            }
            if let profile = responseDict[APIKeys.kUser]![APIKeys.kProfile] as? JSONDictionary {
                if let imageUrl = profile[APIKeys.kImageURL] as? String {
                    UserDataModel.userDetailsDictionary.updateValue(imageUrl, forKey: kImageURLString)
                }
                if let gender = profile[APIKeys.kGender] as? String {
                    UserDataModel.userDetailsDictionary.updateValue(gender, forKey: kGender)
                }
            }
            
            if let health = responseDict[APIKeys.kUser]![APIKeys.kHealth] as? JSONDictionary {
                
                if let height = health[APIKeys.kHeight] as? JSONDictionary {
                    UserDataModel.HeightDict[kHeight] = (height[APIKeys.kValue] as! Double).bygDoubleString()
                    UserDataModel.HeightDict[kUnit] = height[APIKeys.kUnit] as? String
                }
                
                if let weight = health[APIKeys.kWeight] as? JSONDictionary {
                    UserDataModel.WeightDict[kWeight] = (weight[APIKeys.kValue] as! Double).bygDoubleString()
                    UserDataModel.WeightDict[kUnit] = weight[APIKeys.kUnit] as? String
                }
                
                if let idealWeight = health[APIKeys.kIdealWeight] as? JSONDictionary {
                    UserDataModel.WeightDict[kIdealWeight] = (idealWeight[APIKeys.kValue] as! Double).bygDoubleString()
                    UserDataModel.WeightDict[kUnit] = idealWeight[APIKeys.kUnit] as? String
                }
                
                if let lifeStyle = health[APIKeys.kLifeStyle] as? String {
                    UserDataModel.userDetailsDictionary[kLifeStyle] = lifeStyle
                    for index in 0 ..< UserDataModel.LifeStyleArray.count {
                        if(UserDataModel.LifeStyleArray[index] == lifeStyle) {
                            UserDataModel.LifeStyleSelectedIndex = index
                            break
                        }
                    }
                }
                
            }
            
            if let fitness = responseDict[APIKeys.kUser]![APIKeys.kFitness] as? JSONDictionary {
                
                if let level = fitness[APIKeys.kLevel] as? String {
                    UserDataModel.userDetailsDictionary[kFitnessLevel] = level
                    for index in 0 ..< UserDataModel.FitnessLevelArray.count {
                        if(UserDataModel.FitnessLevelArray[index] == level) {
                            UserDataModel.FitnessLevelSelectedIndex = index
                            break
                        }
                    }
                }
                
                if let goals = fitness[APIKeys.kGoals] as? NSArray {
                    for goal in goals {
                        UserDataModel.GoalDict[goal as! String] = true
                    }
                }
                
                if let preferredWorkout = fitness[APIKeys.kPreferredWorkout] as? NSArray {
                    for workout in preferredWorkout {
                        UserDataModel.PreferredWorkoutDict[workout as! String] = true
                    }
                }
                
            }
            
            
            let preferences = responseDict[APIKeys.kUser]![APIKeys.kPreferences] as! JSONDictionary
            for (key,value) in preferences {
                UserDataModel.notificationsDictionary.updateValue((value as? Bool)!, forKey: key)
            }
            DataManager.isProfileCompleted = responseDict[APIKeys.kUser]![APIKeys.kIsCompleted] as! Bool
            
            UserDataModel.userDetailsDictionary.updateValue(responseDict[APIKeys.kUser]![APIKeys.kWallet]!![APIKeys.kAmount] as! Int, forKey: kWalletAmount)
            
            UserDataModel.userDetailsDictionary.updateValue(responseDict[APIKeys.kUser]![APIKeys.kUserID] as! String, forKey: kUserId)
            
            UserDataModel.userDetailsDictionary.updateValue(responseDict[APIKeys.kUser]![APIKeys.kReferalCode] as! String, forKey: kReferalCode)
        }
        
    }

}
