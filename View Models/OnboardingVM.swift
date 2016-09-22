//
//  OnboardingVM.swift
//  BygApp
//
//  Created by Prince Agrawal on 07/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

@objc protocol OnboardingVMDelegate {
    func didConnectWithFacebook(success: Bool, error: NSError?)
    func didFetchFacebookProfile(success: Bool, error: NSError?)
    func didCompletePhoneVerification(success: Bool, error: NSError?, token: String?)

}

@objc protocol HTMLDataDelegate {
    func didFetchAppData(success: Bool, error: NSError?)
}

@objc protocol FetchLocationDelegate {
    func didFetchLocation(success: Bool, error: NSError?)
}

@objc protocol FetchAddressDelegate {
    
    func didFetchAddress(success: Bool, error: NSError?)
}

@objc protocol FetchAnnotationDelegate {
    
    func didFetchAnnotations(success: Bool, error: NSError?)
}

class OnboardingVM: NSObject {
    
    struct Location {
        var address: String
        var latitude: Double
        var longitude: Double
    }
    
    struct GymDetails {
        var name: String
        var imageUrl: String
        var address: String
        var Rating: Float
        var phoneNumber: String
        var distance: Double
        var lowestPrice: Double
        var latitude: Double
        var longitude: Double
    }
    
    
    var annotationsDict:[String :GymDetails]?
    
    var locationsArray:[Location]?
    var selectedLocation: Location?
    var displayAddress = ""
    weak var onboardingDelegate: OnboardingVMDelegate?
    weak var locationDelegate: FetchLocationDelegate?
    weak var addressDelegate: FetchAddressDelegate?
    weak var annotationDelegate: FetchAnnotationDelegate?
    weak var htmlDelegate: HTMLDataDelegate?
    var htmlData: String?
    
    class func isUserLoggedIn() -> Bool {
        if DataManager.jwtToken == nil {
            return false
        }
        else {
            return true
        }
    }
    
    func connectWithFacebook() {
        let facebookSuite = FacebookLoginSuite()
        if let viewController = self.onboardingDelegate as? UIViewController {
            facebookSuite.signInWithController(viewController, success: { (didSuccess, response) in
                
                if didSuccess {
                    facebookSuite.userProfile(success: { (didSuccess, response) in
                        
                        if let response = response as? JSONDictionary {
                            let facebookID = response[kFBID] as! String
                            let name = response[kFBName] as! String
                            let email = response[kFBEmail] as? String
                            
                            APIManager.loginWithFacebook(name, email: email, socialId: facebookID, provider: "Facebook", platform: "iOS", deviceToken: DataManager.deviceToken, successCallback: { (responseDict) in
                                debugPrint(responseDict)
                                self.onboardingDelegate?.didConnectWithFacebook(true, error: nil)
                                }, failureCallback: { (errorReason, error) in
                                    self.onboardingDelegate?.didConnectWithFacebook(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
                            })
                        }
                        
                        self.onboardingDelegate?.didFetchFacebookProfile(true, error: nil)
                        
                        
                        }, error: { (errorReason, error) in
                            self.onboardingDelegate?.didFetchFacebookProfile(false, error: NSError(domain: "Facebook", code: 1, userInfo: [kMessage:errorReason]))
                    })
                }
                
                
                }, error: { (errorReason, error) in
                    self.onboardingDelegate?.didConnectWithFacebook(false, error: NSError(domain: "Facebook", code: 1, userInfo: [kMessage:errorReason]))
                    debugPrint(errorReason)
            })
        }
    }
    
    func connectWithPhone() {
        if let viewController = self.onboardingDelegate as? UIViewController {
            PhoneLoginSuite.sharedInstance.delegate = self
            PhoneLoginSuite.sharedInstance.validateUserLogin(viewController)
        }
        else {
            debugPrint("OnboardingVMDelegate should be of UIViewcontroller type.")
        }
    }
    
    func enablePushNotifications() {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate?.registerApplicationForRemoteNotifications()
    }
    
    func enableLocationServices() {
        
    }
    
    func fetchMapLocations(searchText: String) {
        
        APIManager.fetchLocation(searchText, successCallback: { (response) in
            debugPrint(response)
            self.parseLocationsFromResponse(response!)
            self.locationDelegate?.didFetchLocation(true, error: nil)
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.locationDelegate?.didFetchLocation(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func fetchAddress(latitude: Double, longitude: Double) {
        APIManager.fetchAddress(latitude, longitude: longitude, successCallback: { [weak self](responseDict) in
            debugPrint(responseDict)
            self?.selectedLocation = self?.locationFromResponse(responseDict!, latitude: latitude, longitude: longitude)
            self?.addressDelegate?.didFetchAddress(true, error: nil)
            
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.addressDelegate?.didFetchAddress(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func fetchNearGyms(latitude: Double, longitude: Double, distance: Float) {
        APIManager.fetchNearGyms(latitude, longitude: longitude, distance: distance, successCallback: { (responseDict) in
            debugPrint(responseDict)
            self.parseAnnotationsFromResponse(responseDict!)
            self.annotationDelegate?.didFetchAnnotations(true, error: nil)
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.annotationDelegate?.didFetchAnnotations(false, error:APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func getHTMLData(dataType: String) {
        APIManager.getHTMLData(dataType, successCallback: { (responseDict) in
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.htmlData = responseDict![APIKeys.kContent] as? String
                self.htmlDelegate?.didFetchAppData(true, error: nil)
            }
            }) { (errorReason, error) in
                debugPrint(errorReason)
                self.htmlDelegate?.didFetchAppData(false, error:APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    //MARK: Private Functions
    
    private func locationFromResponse(responseDict: JSONDictionary, latitude: Double, longitude: Double) ->Location {
        var location = Location(address: "", latitude: latitude, longitude: longitude)
        displayAddress = ""
        if(responseDict["status"] as? Int == 1) {
            let components = responseDict["location"]!["components"] as? JSONArray
            var selectedAddress = ""
            var subLocality1: String?
            var subLocality2: String?
            var city: String?
            var state: String?
            var country: String?
            for locality in components! {
                if((locality["types"]?.containsObject("SUBLOCALITY_LEVEL_2")) == true) {
                    subLocality1 = locality["longName"] as? String
                }
                if((locality["types"]?.containsObject("SUBLOCALITY_LEVEL_1")) == true) {
                    subLocality2 = locality["longName"] as? String
                    break
                }
                if((locality["types"]?.containsObject("LOCALITY")) == true) {
                    city = locality["longName"] as? String
                    break
                }
                if((locality["types"]?.containsObject("ADMINISTRATIVE_AREA_LEVEL_1")) == true) {
                    state = locality["longName"] as? String
                    break
                }
                if((locality["types"]?.containsObject("COUNTRY")) == true) {
                    country = locality["longName"] as? String
                    break
                }
            }
            if(subLocality1 != nil) {
                selectedAddress = subLocality1!
                displayAddress = subLocality1!
            }
            if(subLocality2 != nil) {
                if(displayAddress == "") {
                    displayAddress = subLocality2!
                    selectedAddress = subLocality2!
                }
                else {
                    displayAddress = "\(displayAddress), \(subLocality2!)"
                }
            }
            else if(city != nil) {
                selectedAddress = city!
            }
            else if(state != nil) {
                selectedAddress = state!
            }
            else if(country != nil) {
                selectedAddress = country!
            }
            
            location = Location(address: selectedAddress, latitude: latitude, longitude: longitude)
        }
        
        return location
    }
    
    private func parseLocationsFromResponse(responseDict: JSONDictionary) {
        
        locationsArray = nil
        
        let locations = responseDict["locations"] as? JSONArray
        
        for locationDict in locations! {
            let address=locationDict["address"] as? String ?? ""
            let lat=locationDict["lat"] as? Double ?? 0
            let long=locationDict["lng"] as? Double ?? 0
            
            let location = Location(address: address, latitude: lat, longitude: long)
            if locationsArray == nil{
                locationsArray = [Location]()
            }
            locationsArray?.append(location)
        }
    }
    
    private func parseAnnotationsFromResponse(responseDict: JSONDictionary) {
        
        annotationsDict = nil
        if(responseDict["status"] as? Int == 1) {
            
            let gyms = responseDict["gyms"] as? JSONArray
            
            for gymDict in gyms! {
                let address=gymDict["place"] as? String ?? ""
                let lat=gymDict["lat"] as? Double ?? 0
                let long=gymDict["lng"] as? Double ?? 0
                let name=gymDict["name"] as? String ?? ""
                let phone=gymDict["phone"] as? String ?? ""
                let imageUrl=gymDict["logoUrl"] as? String ?? ""
                let lowestPrice=gymDict["lowestPrice"] as? Double ?? 0
                let rating=gymDict["rating"] as? Float ?? 0
                let distanceDouble = gymDict["distance"] as? Double ?? 0
                let distance = Double(round(100*distanceDouble)/100)
                
                let id=gymDict["id"] as? String ?? ""
                
                let gymDetails = GymDetails(name: name, imageUrl: imageUrl, address: address, Rating: rating, phoneNumber: phone, distance: distance, lowestPrice: lowestPrice, latitude: lat, longitude: long)
                if(annotationsDict == nil) {
                    annotationsDict = [String:GymDetails]()
                }
                annotationsDict![id] = gymDetails
            }
        }
    }
}

extension OnboardingVM: PhoneLoginSuiteDelegate {
    
    func phoneVerificationDidSuccess(token: String, phoneNumber: String) {
        
        APIManager.loginWithPhone(phoneNumber, platform: "iOS", deviceToken: DataManager.deviceToken, countryCode: "91", countryIso: "IN", successCallback: { (responeDict) in
            debugPrint(responeDict)
            self.onboardingDelegate?.didCompletePhoneVerification(true, error: nil, token: token)
        }) { (errorReason, error) in
            debugPrint(error?.localizedFailureReason)
            self.onboardingDelegate?.didCompletePhoneVerification(false, error:APIManager.errorForNetworkErrorReason(errorReason!), token: nil)
        }
    }
    
    func phoneVerificationDidFailWithError(error: NSError) {
        onboardingDelegate?.didCompletePhoneVerification(false, error:error, token: nil)
    }
    
}

