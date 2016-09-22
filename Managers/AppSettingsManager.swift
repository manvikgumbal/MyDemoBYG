//
//  AppSettingsManager.swift
//  BygApp
//
//  Created by Prince Agrawal on 02/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

//MARK: App Lifecycle Method calls
func initialiseAppWhileLaunching(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
    initiateAnalytics()
    FacebookLoginSuite.activateApp(application, didFinishLaunchingWithOptions:launchOptions)
    MapsSuite.setupMapsForFirstUse()
}

func updateAppDataWhenAppComesOnForeground() {
    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
}

//MARK: Push Notification Settings

func setupPushNotification() {
    let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
    let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
    
    UIApplication.sharedApplication().registerUserNotificationSettings(pushNotificationSettings)
    UIApplication.sharedApplication().registerForRemoteNotifications()
}

func updatePushNotificationDeviceToken(deviceToken: NSData) {
    // post the device token to servers
    updateDeviceTokenToChatServer(deviceToken)
    AnalyticsSuite.updateDeviceToken(deviceToken)
    
    let tokenString = deviceToken.description as String
    DataManager.deviceToken = tokenString
}

func removePushNotificationDeviceToken() {
    //TODO: remove locally saved token
}

func handlePushNotification(userInfo : [NSObject : AnyObject], applicationState : UIApplicationState) {
    handleChatNotifications(userInfo, applicationState: applicationState)
    AnalyticsSuite.handleAnalyticsNotification(userInfo, applicationState: applicationState)
    //TODO: Handle the notification received.
}


//MARK: Analytics Settings
private func initiateAnalytics() {
    AnalyticsSuite.initialiseAnalyticsTools()
}
