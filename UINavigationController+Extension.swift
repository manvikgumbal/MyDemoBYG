//
//  UINavigationController+Extension.swift
//  BygApp
//
//  Created by Prince Agrawal on 14/08/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

extension UINavigationController {
    func pushViewControllerWithCustomAnimation(viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFromBottom
        view.layer.addAnimation(transition, forKey: nil)
        _ = pushViewController(viewController, animated: false)
    }
    
    func popViewControllerWithCustomAnimation() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFromTop
        view.layer.addAnimation(transition, forKey: nil)
        _ = popViewControllerAnimated(false)
    }
}