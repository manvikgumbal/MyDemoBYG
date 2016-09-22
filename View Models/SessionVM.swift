//
//  SessionVM.swift
//  BygApp
//
//  Created by Manish on 30/08/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

class SessionVM {
    
    static let sharedInstance = SessionVM()
    private init() {}
    
    func showPopupAfterLogin(customPopUp: CustomPopUpView, forView: UIView) {
        if(DataManager.isFirstTimeLogin == false && UserDataModel.userDetailsDictionary[kReferredBy] as! Double == 0) {
            DataManager.isFirstTimeLogin = true
            DataManager.lastDayPopUp = NSDate()
            DataManager.totalLogins = 0
            customPopUp.loadData("refer_friend", titleString:kReferTitle, descriptionString: kReferDescripton.localized, textFieldPlaceholder: "Enter Code", mainButtonTitle: kReferButtonTitle.localized, cancelButtonTitle: "No Thanks!")
            forView.addSubview(customPopUp)
            forView.bringSubviewToFront(customPopUp)
        }
        else if((DataManager.totalLogins == 10 || NSDate.daysBetweenDates(DataManager.lastDayPopUp) == 5 ) && (DataManager.isProfileCompleted == false)) {
            DataManager.totalLogins = 0
            DataManager.lastDayPopUp = NSDate()
            customPopUp.loadData("profile_popup", titleString: kCompleteProfileTitle.localized, descriptionString: kCompleteProfileDescription.localized, textFieldPlaceholder: nil, mainButtonTitle: "Complete now", cancelButtonTitle: "No Thanks!")
            forView.addSubview(customPopUp)
            forView.bringSubviewToFront(customPopUp)
        }
    }
    
    func showRateUsView(rateView: RateUsView, forView: UIView) {
        forView.addSubview(rateView)
        forView.bringSubviewToFront(rateView)
    }
    
    func showReferPopUp(customPopUp: CustomPopUpView, forView: UIView) {
        if(UserDataModel.userDetailsDictionary[kWalletAmount] == 0 && DataManager.isReferDone == false) {
            DataManager.isReferDone = true
            customPopUp.loadData("refer_friend", titleString: "Refer and Inspire", descriptionString: "Refer your friend and earn BYG Money", textFieldPlaceholder: nil, mainButtonTitle: "Refer Now", cancelButtonTitle: "No Thanks!")
            forView.addSubview(customPopUp)
            forView.bringSubviewToFront(customPopUp)
        }
    }
}