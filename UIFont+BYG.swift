//
//  UIFont+BYG.swift
//  BYG
//
//  Created by Prince on 07/07/16.
//  Copyright © 2016 BYG. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
  
  enum BYGFont: String {
    case Regular = "SFUIDisplay-Regular"
    case Medium = "SFUIDisplay-Medium"
    case Bold = "SFUIDisplay-Bold"
    
    func fontWithSize(size: CGFloat) -> UIFont {
      return UIFont(name: rawValue, size: size)!
    }
  }
}