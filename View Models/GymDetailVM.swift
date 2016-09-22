//
//  GymDetailVM.swift
//  BygApp
//
//  Created by Prince Agrawal on 22/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

@objc protocol GymDetailVMDelegate {
    optional func didGetAllGymList(success: Bool, error: NSError?)
    optional func didGetGymListForCategory(index: Int, success: Bool, error: NSError?)
    optional func didGetServicesForGym(gymID: String, success: Bool, error: NSError?)
    optional func didGetOffers(success: Bool, error: NSError?)
    optional func didGetCoupons(success: Bool, error: NSError?)
}

@objc protocol RecentGymsDelegate {
    optional func didGetRecentGyms(success: Bool, error: NSError?)
    optional func didGetSearchedGyms(success: Bool, error: NSError?)
}

@objc protocol GymFormDelegate {
    func didGymFormUpdate(success: Bool, error: NSError?)
}

class GymDetailVM {
    
    weak var delegate: GymDetailVMDelegate?
    weak var recentGymDelegate: RecentGymsDelegate?
    weak var gymFormDelegate: GymFormDelegate?
    
    var coupons = [Coupon]()
    
    var selectedGymID: String!
    var selectedCategoryIndex: Int!
    
    init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onChangeNotification), name: kLocationChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onChangeNotification), name: kFilterChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: Public Functions
    func listOfCategories() ->[String] {
        var categories = [String]()
        for category in GymDetailDataModel.categories {
            categories.append(category.name)
        }
        return categories
    }
    
    func listOfGymsForCategory(index: Int)-> [Gym] {
        var gymArrayToReturn = [Gym]()
        if index == 0 {
            gymArrayToReturn = Array(GymDetailDataModel.gyms.values)
        }
        else {
            for gymID in GymDetailDataModel.categories[index].gyms {
                gymArrayToReturn.append(GymDetailDataModel.gyms[gymID]!)
            }
        }
        
        //Get New GymList if data is zero
        if gymArrayToReturn.count == 0 {
            getNewGymListForCategoryAtIndex(index)
        }
        
        return gymArrayToReturn.sort{ $0.distance < $1.distance}
    }
    
    func getNewGymListForCategoryAtIndex(index:Int) {
        if index == 0 {
            callAPIToGetListOfAllGyms()
        }
        else {
            callAPIToGetListOfGymsForCategory(index)
        }
    }
    
    func gymWithID(gymID: String)-> Gym? {
        if let gym = GymDetailDataModel.gyms[gymID] {
            return gym
        }
        return nil
    }
    
    func servicesForSelectedGym() -> GymService {
        var gymService = GymService()
        if let service = GymDetailDataModel.gyms[selectedGymID]?.services {
            gymService = service
        }
        else {
            callAPIToFetchServicesForGym(selectedGymID)
        }
        return gymService
    }
    
    func getRecentSearchGymDetails() {
        
        GymDetailDataModel.recentGyms = [String: String]()
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let filePath = documentsDirectory.stringByAppendingPathComponent("RecentGyms.plist")
        let recentGymDict = NSDictionary(contentsOfFile: filePath)
        if(recentGymDict != nil) {
            for gym in recentGymDict! {
                GymDetailDataModel.recentGyms![gym.key as! String] = gym.value as? String
            }
        }
        recentGymDelegate?.didGetRecentGyms?(true, error: nil)
    }
    
    func fetchAvailableCoupons() {
        APIManager.fetchAvailableCoupons({ (responseDict) in
            self.parseCouponsFromResponse(responseDict!)
            self.delegate?.didGetCoupons?(true, error: nil)
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.delegate?.didGetCoupons?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    

    
    func updateRecentGymDetails(gymId: String, gymName: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let filePath = documentsDirectory.stringByAppendingPathComponent("RecentGyms.plist")
        var recentGymDict = NSMutableDictionary(contentsOfFile: filePath)
        if(recentGymDict==nil) {
            recentGymDict = NSMutableDictionary()
        }
        recentGymDict?.setValue(gymName, forKey: gymId)
        recentGymDict?.writeToFile(filePath, atomically: true)
    }
    
    func searchedGyms() ->[String: Gym]? {
        return GymDetailDataModel.searchedGyms
    }
    
    func recentGyms() ->[String: String]? {
        return GymDetailDataModel.recentGyms
    }
    
    func refreshGymList(listIndex: Int) {
        GymDetailDataModel.categories[listIndex].nextPage = 1
        if listIndex == 0 {
            callAPIToGetListOfAllGyms()
        }
        else {
            callAPIToGetListOfGymsForCategory(listIndex)
        }
    }
    
    func ongoingOffers() ->[Offer] {
        if GymDetailDataModel.ongoingOffers.count == 0 {
            callAPIToGetOffers()
        }
        
        if GymDetailDataModel.gyms.count == 0 {
            return [Offer]()
        }
        else {
            return GymDetailDataModel.ongoingOffers
        }
    }
    
    //MARK: Private Functions
    @objc private func onChangeNotification() {
        GymDetailDataModel.categories[0].nextPage = 1
        callAPIToGetListOfAllGyms()
    }
    
    private func parseCouponsFromResponse(response: JSONDictionary) {
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
        }
    }

    
    //MARK: API Calls
    
    private func callAPIToGetListOfAllGyms() {
        var nextPage = GymDetailDataModel.categories[0].nextPage
        var previousPage = GymDetailDataModel.categories[0].previousPage
        if  nextPage > 0 {
            let latitude = DataManager.selectedLocation![kLatitude] as! Double
            let longitude = DataManager.selectedLocation![kLongitude] as! Double
            let filter = GymDetailDataModel.appliedFilter
            let isFilterApplied = filter == nil ? false:true
            
            var filteredCategories:[String]?
            for category in filter?.categories ?? [] {
                if filteredCategories == nil {
                    filteredCategories = [String]()
                }
                filteredCategories!.append(category.categoryID)
            }
            
            var distance = kDefaultDistance
            if isFilterApplied {
                distance = filter!.distance ?? kDefaultDistance
            }
            APIManager.getListOfGyms(latitude, longitude: longitude, distance: distance, page: nextPage, size: kDefaultSize, filter: isFilterApplied, category: filteredCategories, preferred: filter?.isBYGPreferred, popular: filter?.isPopular, rating: filter?.ratings, priceType: filter?.priceRange,successCallback: { [weak self](response) in
                
                if let next = response?[APIKeys.kNextPage] as? Int, let prevPage = response?[APIKeys.kPreviousPage] as? Int {
                    nextPage = next
                    previousPage = prevPage
                    
                    if  (nextPage == 0) && (prevPage == 0) {
                        var errorCode: DataErrorCode!
                        var message = ""
                        if GymDetailDataModel.appliedFilter != nil {
                            errorCode = DataErrorCode.NoDataForFilter
                            message = "No Gyms in the selected location"
                        }
                        else {
                            errorCode = DataErrorCode.NoDataForLocation
                            message = "No gyms for the filter applied"
                        }
                        let error = NSError(domain: "Sorry", code: errorCode.rawValue, userInfo: [kMessage: message])
                        self?.delegate?.didGetAllGymList?(false, error: error)
                    }
                        
                        
                    else {
                        if let services = response?[APIKeys.kCategories] as? JSONArray {
                            GymDetailDataModel.categories.removeAll()
                            GymDetailDataModel.parseCategoryListFromResponse(services)
                            
                            if let gyms = response?[APIKeys.kGyms] as? JSONArray {
                                if prevPage  == 0 || nextPage == 2 { //Clean All gym details if its the first page data
                                    GymDetailDataModel.gyms.removeAll()
                                }
                                
                                GymDetailDataModel.updateGymListFromResponse(gyms, categoryIndex: 0, nextPage: nextPage, prevPage: previousPage)
                            }
                            self?.delegate?.didGetAllGymList?(true, error: nil)
                        }
                    }
                }
            }) { [weak self](errorReason, error) in
                self?.delegate?.didGetAllGymList?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
            }
        }
        else if previousPage == 0 {
            let error = NSError(domain: "Sorry", code: 0, userInfo: [kMessage: "No Gyms in the selected location"])
            delegate?.didGetAllGymList?(false, error: error)
        }
    }
    
    private func callAPIToGetListOfGymsForCategory(index: Int) {
        var nextPage = GymDetailDataModel.categories[index].nextPage
        var previousPage = GymDetailDataModel.categories[index].previousPage
        if nextPage > 0 {
            let latitude = DataManager.selectedLocation![kLatitude] as! Double
            let longitude = DataManager.selectedLocation![kLongitude] as! Double
            
            let filter = GymDetailDataModel.appliedFilter
            let isFilterApplied = filter == nil ? false:true
            
            var filteredCategories:[String]?
            for category in filter?.categories ?? [] {
                if filteredCategories == nil {
                    filteredCategories = [String]()
                }
                filteredCategories!.append(category.categoryID)
            }
            
            var distance = kDefaultDistance
            if isFilterApplied {
                distance = filter!.distance ?? kDefaultDistance
            }
            
            APIManager.getListOfGymsForCategory(latitude, longitude: longitude, distance: distance, page: nextPage, size: kDefaultSize, categoryID: GymDetailDataModel.categories[index].categoryID, filter: isFilterApplied, category: filteredCategories, preferred: filter?.isBYGPreferred, popular: filter?.isPopular, rating: filter?.ratings, priceType: filter?.priceRange,successCallback: { [weak self](response) in
                
                if let next = response?[APIKeys.kNextPage] as? Int, let prevPage = response?[APIKeys.kPreviousPage] as? Int {
                    nextPage = next
                    previousPage = prevPage
                }
                
                if let gyms = response?[APIKeys.kGyms] as? JSONArray {
                    GymDetailDataModel.updateGymListFromResponse(gyms, categoryIndex: index, nextPage: nextPage, prevPage: previousPage)
                }
                else {
                    let error = NSError(domain: "Sorry", code: 0, userInfo: [kMessage: "Unrecognized data"])
                    self?.delegate?.didGetGymListForCategory?(index, success: false, error: error)
                    return
                }
                
                self?.delegate?.didGetGymListForCategory?(index, success: true, error: nil)
                
            }) { [weak self](errorReason, error) in
                self?.delegate?.didGetGymListForCategory?(index, success: false, error: APIManager.errorForNetworkErrorReason(errorReason!))
            }
        }
        else if previousPage == 0 {
            let error = NSError(domain: "Sorry", code: 0, userInfo: [kMessage: "No Gyms in the selected location"])
            delegate?.didGetGymListForCategory?(index, success: false, error: error)
        }
    }
    
    private func callAPIToFetchServicesForGym(gymID:String) {
        let latitude = DataManager.selectedLocation![kLatitude] as! Double
        let longitude = DataManager.selectedLocation![kLongitude] as! Double
        APIManager.getServicesForGym(gymID, latitude: latitude, longitude: longitude, successCallback: { [weak self](response) in
            if GymDetailDataModel.gyms[gymID] == nil {
                if let gymDict = response?[APIKeys.kGym] as? JSONDictionary {
                    if let newGym = GymDetailDataModel.parsedGymFromResponse(gymDict) {
                    GymDetailDataModel.gyms.updateValue(newGym, forKey: newGym.gymID)
                    }
                }
            }
            if let servicesDict = response?[APIKeys.kServices] as? JSONDictionary {
                GymDetailDataModel.parseGymServicesFromResponse(servicesDict, gymID: gymID)
            }
            
            if let ratings = response?[APIKeys.kRatings] as? JSONArray {
                GymDetailDataModel.parseGymRatingsFromResponse(ratings, gymID: gymID)
            }
            self?.delegate?.didGetServicesForGym?(gymID, success: true, error: nil)
            
        }) { [weak self](errorReason, error) in
            debugPrint(errorReason)
            self?.delegate?.didGetServicesForGym?(gymID, success: false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    
    func callAPIToSearchGyms(searchText: String, latitude: Double, longitude: Double, distance: Double) {
        APIManager.fetchSearchGyms(searchText,latitude: latitude, longitude: longitude, distance: distance, successCallback: {[weak self] (responseDict) in
            debugPrint(responseDict)
            GymDetailDataModel.parseSearchGymsResponse(responseDict!)
            self?.recentGymDelegate?.didGetSearchedGyms?(true, error: nil)
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.recentGymDelegate?.didGetSearchedGyms?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func callAPIToGetOffers() {
        APIManager.getOffers({ (responseDict) in
            debugPrint(responseDict)
            if let response = responseDict as JSONDictionary? {
                GymDetailDataModel.parseOffersFromResponse(response)
                self.delegate?.didGetOffers?(true, error: nil)
            }
        }) { (errorReason, error) in
            debugPrint(errorReason)
            self.delegate?.didGetOffers?(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
    
    func callAPIToUpdateGymForm(name: String, address: String, comments: String?) {
        APIManager.updateGymForm(name, address: address, comments: comments, successCallback: { (responseDict) in
            debugPrint(responseDict)
            if(responseDict![APIKeys.kStatusBool] as! Int == 1) {
                self.gymFormDelegate?.didGymFormUpdate(true, error: nil)
            }
        }) { (errorReason, error) in
            self.gymFormDelegate?.didGymFormUpdate(false, error: APIManager.errorForNetworkErrorReason(errorReason!))
        }
    }
}
