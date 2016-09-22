//
//  UIColor+BYG.swift
//  BygApp
//
//  Created by Prince Agrawal on 16/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    enum BYGColor  {
        case Default
        case ShadowColor
        
        func colorWithAlpha(alpha: CGFloat) -> UIColor {
            var colorToReturn:UIColor?
            switch self {
            case .Default:
                colorToReturn = UIColor(red: 238/255, green: 43/255, blue: 46/255, alpha: alpha)
                
            case .ShadowColor:
                colorToReturn = UIColor.blackColor().colorWithAlphaComponent(0.5)
            }
            
            return colorToReturn!
        }
    }
}
