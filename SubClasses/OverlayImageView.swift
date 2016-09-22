//
//  OverlayImageView.swift
//  BygApp
//
//  Created by Prince Agrawal on 14/07/16.
//  Copyright © 2016 Book Your Game Fitness Pvt. Ltd. All rights reserved.
//

import UIKit


class OverlayImageView: UIImageView {
    @IBInspectable var overlayOpacity: CGFloat = 0.60 {
        didSet {
            overlayView.backgroundColor = overlayColor.colorWithAlphaComponent(overlayOpacity)
        }
    }
    
    @IBInspectable var overlayColor: UIColor = UIColor.blackColor() {
        didSet {
            overlayView.backgroundColor = overlayColor.colorWithAlphaComponent(overlayOpacity)
        }
    }

    
    @IBInspectable var radius: CGFloat = 40.0 {
        didSet {
            
            self.layer.cornerRadius=radius
            self.layer.masksToBounds=true
        }
    }
    
    var overlayView = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        overlayView.frame = frame
        overlayView.frame.origin = CGPointMake(0, 0)
        overlayView.backgroundColor = overlayColor.colorWithAlphaComponent(overlayOpacity)
        addSubview(overlayView)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        overlayView.frame = frame
        overlayView.frame.origin = CGPointMake(0, 0)
    }
}