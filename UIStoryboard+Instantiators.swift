//
//  UIStoryboard+Instantiators.swift
//  BygApp
//
//  Created by Prince Agrawal on 11/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(self)
    }
}

extension UIStoryboard  {
    
    /// The uniform place where we state all the storyboard we have in our application
    
    enum Storyboard : String {
        case Main
        case Onboarding
        case Bookings
        case Wallet
        case WorkoutNow
        case Cart
        case Settings
    }
    
    /// Convenience Initializers
    convenience init(storyboard: Storyboard, bundle: NSBundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    class func storyboard(storyboard: Storyboard, bundle: NSBundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
    }
    
    /// View Controller Instantiation from Generics
    func instantiateViewController<T: UIViewController where T: StoryboardIdentifiable>() -> T {
        guard let viewController = self.instantiateViewControllerWithIdentifier(T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        
        return viewController
    }
}


// Conform Protocol to all the view controllers

extension UIViewController : StoryboardIdentifiable {
    
}
