//
//  UITextField+BYG.swift
//  BygApp
//
//  Created by Manish on 4/08/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import Foundation

extension UITextField {
    
    func setBorderWithRadius(borderWidth: CGFloat?, borderColor: UIColor?, radius: CGFloat?) {
        
        self.layer.borderColor = borderColor?.CGColor
        self.layer.borderWidth = borderWidth!
        self.layer.cornerRadius = radius!
        self.layer.masksToBounds=true
        
    }
}