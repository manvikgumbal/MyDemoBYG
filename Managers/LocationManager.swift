//
//  LocationManager.swift
//  BygApp
//
//  Created by Prince Agrawal on 07/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation
import CoreLocation

//possible errors
enum LocationManagerErrorReason: Int {
    case LocationDisabled
    case AuthorizationDenied
    case AuthorizationRestricted
    case AuthorizationNotDetermined
    case InvokeCallback
    case OtherReason
}

class LocationManager: NSObject {
    //location manager
    static let sharedManager = LocationManager()
    private var locationManager: CLLocationManager?
    private var needPlacemark = true
    private var shouldInvokeCallback = false  {
        didSet {
            if shouldInvokeCallback {
                invokeLocationCallBack()
            }
        }
    }//To fix the iOS bug. iOS never gives call back if location permission is disabled and location permission is asked twice
    
    override private init() {
        //create the location manager
        locationManager = CLLocationManager()
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    typealias LocationManagerCallback = ((location: CLLocation?, placemark: CLPlacemark?, errorReason: LocationManagerErrorReason?)->())
    private var didCompleteCallback: LocationManagerCallback?
    
    //location manager method called from delegate methods
    private func locationManagerDidComplete(location: CLLocation?, placemark: CLPlacemark?, errorReason: LocationManagerErrorReason?) {
        locationManager?.stopUpdatingLocation()
        didCompleteCallback?(location: location, placemark: placemark, errorReason: errorReason)
        locationManager?.delegate = nil
    }
    
    //ask for location permissions and fetch locations
    func askPermissionsAndFetchLocationWithCompletion(isPlacemarkRequired: Bool = true, shouldInvokePermissionFailureCallback: Bool = false, completionCallback: LocationManagerCallback) {
        //store the completion closure
        didCompleteCallback = completionCallback
        locationManager!.delegate = self
        needPlacemark = isPlacemarkRequired
        
        if isLoocationAccessEnabled() {
            locationManager?.startUpdatingLocation()
        }
        else {
            let mainBundle = NSBundle.mainBundle()
            if(mainBundle.objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription") != nil) {
                locationManager?.requestWhenInUseAuthorization()
            } else if (mainBundle.objectForInfoDictionaryKey("NSLocationAlwaysUsageDescription") != nil) {
                locationManager?.requestAlwaysAuthorization()
            } else {
                debugPrint("To use location in iOS8 you need to define either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in the app bundle's Info.plist file")
            }
            shouldInvokeCallback = shouldInvokePermissionFailureCallback
        }
    }
    
    func isLoocationAccessEnabled() -> Bool {
        var boolToReturn = false
        locationManager?.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                boolToReturn = false
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                boolToReturn = true
            }
        } else {
            boolToReturn = false
        }
        return boolToReturn
    }
    
    func invokeLocationCallBack() {
        if shouldInvokeCallback {
            didCompleteCallback?(location: nil, placemark: nil, errorReason: .InvokeCallback)
            shouldInvokeCallback = false
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    // MARK: - CLLocation Delegate method implementation
    //location authorization status changed
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() {
            shouldInvokeCallback = false
            switch status {
            case .AuthorizedWhenInUse:
                self.locationManager!.startUpdatingLocation()
            case .Restricted:
                locationManagerDidComplete(nil, placemark: nil, errorReason: .AuthorizationRestricted)
            case .Denied:
                locationManagerDidComplete(nil, placemark: nil, errorReason: .AuthorizationDenied)
            case .NotDetermined:
                locationManager!.requestWhenInUseAuthorization()
            default:
                break
            }
        }
        else {
            shouldInvokeCallback = true
            locationManager!.requestLocation()
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        shouldInvokeCallback = false
        locationManagerDidComplete(nil, placemark: nil, errorReason: .OtherReason)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        shouldInvokeCallback = false
        if let location = locations[0] as CLLocation? {
            locationManager?.stopUpdatingLocation()
            
            if needPlacemark {
                getPlacemarkInfoFromLocation(location)
            }
            else {
                locationManagerDidComplete(location, placemark: nil, errorReason: nil)
            }
        }
        else {
            locationManagerDidComplete(nil, placemark: nil, errorReason: nil)
        }
    }
}

extension LocationManager {
    func getPlacemarkInfoFromLocation(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] (placemarks, error) -> Void in
            if (error != nil) {
                if let error = error {
                    debugPrint(error.localizedDescription)
                    self?.locationManagerDidComplete(location, placemark: nil, errorReason: nil)
                }
            }
            else {
                if placemarks?.count > 0 {
                    let placemark = placemarks![0] as CLPlacemark
                    self?.locationManagerDidComplete(location, placemark: placemark, errorReason: nil)
                }
                else {
                    self?.locationManagerDidComplete(location, placemark: nil, errorReason: nil)
                }
            }
        }
    }
}
